#!/bin/bash

# AI-Powered Git Synchronization Script
# Handles local and remote changes with intelligent commit messages using Claude API

set -e  # Exit on any error

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs) > /dev/null 2>&1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository! Please run this script from within a git repository."
        exit 1
    fi
}

# Function to generate AI-powered commit message using Claude API
generate_commit_message() {
    print_info "Generating intelligent commit message using Claude API..." >&2
    
    # Check if CLAUDE_API_KEY is set
    if [ -z "$CLAUDE_API_KEY" ]; then
        print_warning "CLAUDE_API_KEY not found. Using fallback commit message." >&2
        generate_fallback_commit_message
        return
    fi
    
    # Get the diff of staged changes
    local git_diff=$(git diff --cached --no-color)
    local changed_files=$(git diff --cached --name-only)
    local file_list=$(echo "$changed_files" | tr '\n' ', ' | sed 's/,$//')
    
    # If no staged changes, check unstaged changes
    if [ -z "$git_diff" ]; then
        git_diff=$(git diff --no-color)
        changed_files=$(git diff --name-only)
        file_list=$(echo "$changed_files" | tr '\n' ', ' | sed 's/,$//')
    fi
    
    # If still no changes, check for new files
    if [ -z "$git_diff" ]; then
        local untracked_files=$(git ls-files --others --exclude-standard)
        if [ -n "$untracked_files" ]; then
            file_list=$(echo "$untracked_files" | tr '\n' ', ' | sed 's/,$//')
            git_diff="New files: $file_list"
        fi
    fi
    
    # Truncate diff if it's too long (Claude has token limits)
    local max_diff_length=3000
    if [ ${#git_diff} -gt $max_diff_length ]; then
        git_diff="${git_diff:0:$max_diff_length}
[... diff truncated due to length ...]"
    fi
    
    # Prepare the prompt for Claude (escape for JSON)
    local base_prompt="You are an expert developer assistant. Based on the following git diff, generate a concise, clear commit message that follows conventional commit format (feat:, fix:, docs:, style:, refactor:, test:, chore:, etc.) when appropriate. Generate only the commit message (one line, max 72 characters). Do not include any explanation, quotes, or additional text."
    
    # Escape the git diff for JSON (replace newlines with \n and escape quotes)
    local escaped_diff=$(echo "$git_diff" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ' | sed 's/  */ /g')
    local escaped_files=$(echo "$file_list" | sed 's/"/\\"/g')
    
    # Create a simpler prompt
    local simple_prompt="$base_prompt Files changed: $escaped_files. Changes: $escaped_diff"
    
    # Truncate the entire prompt if too long
    if [ ${#simple_prompt} -gt 2000 ]; then
        simple_prompt="${simple_prompt:0:2000}..."
    fi
    
    # Escape the prompt for JSON
    local escaped_prompt=$(echo "$simple_prompt" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
    
    # Make API call to Claude with properly escaped JSON
    local response=$(curl -s --max-time 10 \
        -H "Content-Type: application/json" \
        -H "x-api-key: $CLAUDE_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "{\"model\":\"claude-3-5-sonnet-20241022\",\"max_tokens\":100,\"messages\":[{\"role\":\"user\",\"content\":\"$escaped_prompt\"}]}" \
        https://api.anthropic.com/v1/messages 2>/dev/null)
    
    # Extract the commit message from the response
    local commit_message=""
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        # Parse JSON response to extract the content
        commit_message=$(echo "$response" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"//' | sed 's/"$//' | sed 's/\\n/ /g')
        
        # Clean up the commit message (remove extra quotes, newlines, etc.)
        commit_message=$(echo "$commit_message" | sed 's/^"//;s/"$//' | tr -d '\n' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
    fi
    
    # Fallback if API call failed or returned empty
    if [ -z "$commit_message" ] || [ "$commit_message" = "null" ]; then
        print_warning "Claude API call failed or returned empty response. Using fallback." >&2
        commit_message=$(generate_fallback_commit_message)
    else
        print_success "Generated commit message: $commit_message" >&2
    fi
    
    echo "$commit_message"
}

# Function to generate fallback commit message when API fails
generate_fallback_commit_message() {
    local changed_files=$(git diff --cached --name-only)
    
    # If no staged changes, check unstaged and untracked
    if [ -z "$changed_files" ]; then
        changed_files=$(git diff --name-only)
        if [ -z "$changed_files" ]; then
            changed_files=$(git ls-files --others --exclude-standard)
        fi
    fi
    
    local file_count=$(echo "$changed_files" | wc -l | tr -d ' ')
    
    if [ "$file_count" -eq 1 ]; then
        local file=$(echo "$changed_files" | head -1)
        echo "Update $file"
    else
        echo "Update $file_count files"
    fi
}

# Function to check if there are local changes (staged or unstaged)
has_local_changes() {
    # Check for staged changes
    if ! git diff --cached --quiet; then
        return 0  # has changes
    fi
    
    # Check for unstaged changes
    if ! git diff --quiet; then
        return 0  # has changes
    fi
    
    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        return 0  # has changes
    fi
    
    return 1  # no changes
}

# Main synchronization function
sync_git() {
    local branch=$(git branch --show-current)
    local remote="origin"
    
    print_info "Starting git synchronization on branch: $branch"
    
    # Check if we're in a git repository
    check_git_repo
    
    # Fetch latest changes from remote
    print_info "Fetching latest changes from remote..."
    git fetch $remote
    
    # Check if remote branch exists
    if ! git show-ref --verify --quiet refs/remotes/$remote/$branch; then
        print_warning "Remote branch $remote/$branch doesn't exist."
        if has_local_changes; then
            print_info "Committing local changes..."
            git add -A
            local commit_msg=$(generate_commit_message)
            git commit -m "$commit_msg"
            print_success "Local changes committed: $commit_msg"
        fi
        print_info "Pushing branch to remote..."
        git push -u $remote $branch
        print_success "Branch pushed to remote successfully!"
        return 0
    fi
    
    # Check the status compared to remote
    local behind=$(git rev-list --count HEAD..$remote/$branch)
    local ahead=$(git rev-list --count $remote/$branch..HEAD)
    
    print_info "Local branch is $ahead commits ahead and $behind commits behind remote"
    
    # Determine what actions to take
    local has_local=$(has_local_changes && echo "true" || echo "false")
    
    print_info "Local changes detected: $has_local"
    print_info "Remote changes: $behind commits behind"
    print_info "Local commits: $ahead commits ahead"
    
    # Simple logic:
    # 1. If there are local changes, commit them
    # 2. If there are remote changes, pull them
    # 3. If there are local commits, push them
    
    # Step 1: Commit local changes if any
    if [ "$has_local" = "true" ]; then
        print_info "Committing local changes..."
        git add -A
        local commit_msg=$(generate_commit_message)
        git commit -m "$commit_msg"
        print_success "Local changes committed: $commit_msg"
        # Update ahead count after committing
        ahead=$((ahead + 1))
    fi
    
    # Step 2: Pull remote changes if any
    if [ $behind -gt 0 ]; then
        print_info "Pulling $behind remote commits..."
        if [ $ahead -gt 0 ]; then
            # Both local and remote changes - merge needed
            print_info "Both local and remote changes detected. Merging..."
            git pull $remote $branch --no-rebase --no-edit
            print_success "Successfully merged remote changes!"
        else
            # Only remote changes - simple pull
            git pull $remote $branch --no-rebase
            print_success "Successfully pulled remote changes!"
        fi
    fi
    
    # Step 3: Push local commits if any
    if [ $ahead -gt 0 ] || [ "$has_local" = "true" ]; then
        print_info "Pushing local commits to remote..."
        git push $remote $branch
        print_success "Successfully pushed local commits!"
    fi
    
    # Final status check
    if [ $behind -eq 0 ] && [ $ahead -eq 0 ] && [ "$has_local" = "false" ]; then
        print_success "Repository is already up to date!"
    else
        print_success "Git synchronization completed successfully!"
    fi
}

# Main execution
main() {
    echo "================================================"
    echo "     AI-Powered Git Synchronization Script"
    echo "================================================"
    echo ""
    
    # Run the synchronization
    sync_git
    
    echo ""
    echo "================================================"
    echo "          Synchronization Complete"
    echo "================================================"
}

# Run main function
main "$@"
