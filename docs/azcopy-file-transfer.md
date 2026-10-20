# Storage: Copying Files to a Storage Account with AzCopy

## Objective
Practise copying files into an Azure Storage account container using AzCopy, and understand how it authenticates and when it is a better choice than the portal.

## What I built
- A **storage account** (`united1`) and a private **container** (`tipi`) in my home lab, with the `Environment` tag added so the Task 1 tag policy would not block it
- Two small test files in an `azcopy-test` folder in Cloud Shell
- A **SAS token** on the container with only Add, Create, Write and List permissions and a short expiry
- A copy of the folder into the `tipi` container using `azcopy copy`
- A second copy with **no SAS token**, using my own Entra ID sign-in and a data role instead

## How I approached it

**Where to run it.** AzCopy is already installed in Azure Cloud Shell. `azcopy --version` printed version 10.33.0, so there was nothing to download. Microsoft's documentation shows AzCopy has been part of Cloud Shell since 2017.

**Why a SAS token instead of signing in.** Being Owner on the subscription covers managing Azure resources, but not reading and writing the data inside a storage account. Signing in with `azcopy login` would need a data role such as Storage Blob Data Contributor first. A SAS token avoids that, because it carries its own permission.

**Limiting the token.** I gave the SAS only the permissions needed (Add, Create, Write, List), scoped it to one container, and set it to expire within the hour. A SAS URL works like a password, so I kept it out of this document.

**Creating the test files.** In Cloud Shell:
- `mkdir azcopy-test` creates a folder for the files
- `"hello from azcopy test 1" | Out-File azcopy-test/file1.txt` writes text into a new file, with the `|` passing the text to `Out-File`
- the same again for `file2.txt`
- `ls azcopy-test` confirms both files exist

**The copy.** I stored the SAS URL in a variable so the long token was not pasted into the command, then ran:

```powershell
$dest = '<container SAS URL>'
azcopy copy "azcopy-test" $dest --recursive
```

- `azcopy copy` is the program and action
- `"azcopy-test"` is the source folder
- `$dest` is the destination container, with the SAS token as the permission
- `--recursive` includes everything inside the folder

## Testing and troubleshooting

**Reading the output.** The summary showed 2 transfers completed, 0 failed, 50 bytes transferred, and a final job status of Completed.

**Empty folders.** AzCopy noted that empty folders are not processed when the destination has no full folder support. In a storage account without a hierarchical namespace, "folders" are only part of a file's name, so an empty folder has nothing to exist as.

**Confirming it worked.** I opened the container in the portal and the files were there.
`[Screenshot: container showing the copied files, with the account URL cropped out]`

## Second attempt: signing in instead of using a SAS token
**Giving myself a data role.** For this route my account needed a role that covers blob data. I assigned **Storage Blob Data Contributor** to my own user on the storage account. Microsoft's documentation says role assignments can take up to five minutes to apply.

**`azcopy login` failed.** The sign-in page told me I couldn't sign in with a personal account and to use a work or school account. My home lab sign-in is a personal Microsoft account, so that route was closed to me.

**Reusing the PowerShell sign-in instead.** Cloud Shell is already signed in through Azure PowerShell, and AzCopy 10.22.0 or newer can reuse that token. Setting the login type tells it to:

```powershell
$Env:AZCOPY_AUTO_LOGIN_TYPE="PSCRED"
```

**Temporary sessions.** When I came back to run this, my `azcopy-test` folder was gone, because it was a new Cloud Shell session. I recreated the folder and made a new file, `file3.txt`.

**The copy.** The destination was the plain container address with no token on the end:

```powershell
azcopy copy "azcopy-test" "https://<storage-account>.blob.core.windows.net/<container>" --recursive
```

`file3.txt` appeared in the container after the copy ran. Creating the file in Cloud Shell did not put it there. The upload only happens when `azcopy copy` runs.

## Copying a real file from my computer
Cloud Shell runs in Azure, so AzCopy there can't see files on my own computer. I used the **Manage files → Upload** button in the Cloud Shell toolbar to put a screenshot onto Cloud Shell's temporary disk, then copied it to the container with the same sign-in as before:

```powershell
azcopy copy "<file name with spaces>.png" "https://<storage-account>.blob.core.windows.net/<container>/screenshot.png"
```

- The source name had spaces in it, so it has to be in quotes
- It is a single file, so `--recursive` isn't needed
- The destination includes the name the file should have in the container

The file appeared in the container. The copy in Cloud Shell disappears when the session ends, but the blob in the container stays.

## Validation summary
- AzCopy available in Cloud Shell without installing anything ✓
- Both test files copied, 0 failures, final status Completed ✓
- Files visible in the container in the portal ✓
- Copy with no SAS token, using my own sign-in and Storage Blob Data Contributor, delivered `file3.txt` to the container ✓
- A real file uploaded through Cloud Shell was copied into the container ✓

## Lessons learned
- Managing a storage account and accessing the data inside it are separate permissions, so Owner alone does not let you write blobs through Entra ID sign-in
- A SAS token is a credential: keep it minimal, short-lived, and out of notes, scripts and repos
- `azcopy login` can fail for personal Microsoft accounts. Reusing the Azure PowerShell sign-in with `AZCOPY_AUTO_LOGIN_TYPE` worked as an alternative
- Cloud Shell sessions are temporary, so files made in one session may be gone in the next
- Uploading through Cloud Shell is a detour. To copy straight from a computer, AzCopy has to run on that computer
- File names with spaces need quotes on the command line
- A tar file is only an archive. The program inside is built for one operating system, so a Linux build will not run on macOS
- For a couple of small files the portal is just as quick. AzCopy is the better tool for many files, large transfers, jobs that need to resume, repeatable scripts, or copying between storage accounts
- The tag and lock policies from the governance tasks still apply to new resources, so a new storage account needs the required tag from the start

## What I'd like to do next
- Try `azcopy sync` to keep a folder and a container matching by copying only changed files
- Run AzCopy from my own machine using the build for my operating system
- Put the copy in a script so it is repeatable

---
*Personal Azure home lab project. Not a production environment.*
