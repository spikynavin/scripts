import os, sys, argparse, git, hashlib
from git import Repo

GITHUB = "https://github.com/"

def check_md5sum(file_path):
    md5sum = hashlib.md5()
    with open(file_path, 'rb') as file:
        # Update the MD5 hash with the binary file content
        md5sum.update(file.read())
    return md5sum.hexdigest()

def write_md5sum(binary_name, md5sum, file_path):
    with open(file_path, 'w') as file:
        file.write(f"Auto-commit latest SFI binary\n\nDescription :- Auto-commit latest SFI binary\nBinary : {binary_name}\nMd5sum : {md5sum}\nVariant :- C0\n")

def clean_rebase_pull(repo):
    # Discard uncommitted changes
    repo.git.reset(hard=True)
    repo.git.clean(f=True, x=True)

    # Fetch the latest changes from the remote
    repo.remotes.origin.fetch()

    # Rebase to the latest commit on the current branch
    repo.git.rebase('origin/' + repo.active_branch.name)


def clone(url, branch=None):

    full_url = GITHUB + url

    base_name = os.path.basename(url.strip("/"))

    repo_name = os.path.splitext(base_name)[0]

    path = os.path.abspath(repo_name)

    if os.path.exists(path) and os.path.isdir(path) and os.path.exists(os.path.join(path, '.git')):
        # If the destination path already exists and is a Git repository, pull the latest changes
        repo = git.Repo(path)
        print(f"Repository at {path} already exists. Pulling latest changes.")
        clean_rebase_pull(repo)
    else:
        # If the destination path does not exist or is not a Git repository, clone the repository
        class Progress(git.remote.RemoteProgress):
            def update(self, op_code, cur_count, max_count=None, message=''):
                sys.stdout.write('\rCloning: {}% {}'.format(int(cur_count / max_count * 100), message))
                sys.stdout.flush()

        repo = git.Repo.clone_from(full_url, path, branch=branch, progress=Progress())
        sys.stdout.write('\n')  # To move to the next line after the progress bar
        print(f"Repository cloned to {path}")

    return repo

def commit_push(repo_path, branch=None, commit_file=None, binpath=None):
    repo = Repo(repo_path)

    # Check if there are changes in the repository
    if not repo.is_dirty(untracked_files=True):
        print("No changes in the repository. Nothing to commit and push.")
        return

    existing_md5sum = check_md5sum(binpath) if binpath else None
    print("Previous binary md5sum:- " + existing_md5sum)

    repo.git.add('--all')

    new_md5sum = check_md5sum(binpath) if binpath else None
    print("New binary md5sum:- " + new_md5sum)

    if commit_file and new_md5sum:
        binary_name = os.path.basename(binpath)
        write_md5sum(binary_name, new_md5sum, commit_file)

    if commit_file:
        with open(commit_file, 'r') as file:
            commit_msg = file.read()
            print(f"Commit message:\n{commit_msg}")
    else:
        commit_msg = "Auto-generated commit message"

    repo.index.commit(commit_msg)
    
    origin = repo.remote(name='origin')
    #origin.push(branch)

def main():
    parser = argparse.ArgumentParser(description="Fetch a git repository")
    parser.add_argument("-l","--url",help="URL of the git repository")
    parser.add_argument("-b","--branch",help="Branch name to checkout when clone")
    parser.add_argument("-p","--path",help="Existing git repository path")
    parser.add_argument("-c","--commit", help="Path to the commit message file")
    parser.add_argument("-s","--binpath",help="binary path for calculate hash")

    args = parser.parse_args()

    # Check if both URL and path arguments are provided
    if args.url and args.path:
        print("Error: Both --url and --path arguments cannot be provided simultaneously.")
        parser.print_help()
        return

    if args.url:
        repo_name = clone(args.url, args.branch)
    elif args.path:
        repo_path = commit_push(args.path, args.branch, args.commit, args.binpath)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
