# Invoke-Unbup
Decrypts McAfee quarantine files

When McAfee quarantines a binary, it XORs and renames the item with random characters, changes the extension to .bup, and typically stores the item in C:\Quarantine. In the end, this all makes the file unusable on the system. This script reverses that process using 7-zip, the publicly known key, and then zips it with a user-defined password. If no password is provided, the default password of "!nf3ct3d!" is used. This script ultimately restores the binary into its orginal state.
