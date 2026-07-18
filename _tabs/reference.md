---
# the default layout is 'page'
icon: fas fa-book-bookmark
order: 5
title: Reference
---

From time to time, I revisit bookmarked websites to remember how or why I configured my computer in a particular way.
That process ends up being more re-learning than remembering because the bookmark never retains the context or conclusions.
This is a reference page to enrich those links with the extra information I need.
As a result, I tend to focus on configuration options that I find useful for my usage.
I hope you find it useful, too.

## Yubikeys

It's good practice to set non-default values for the configuration pins and keys.
Setting new values is easy with [Yubico Authenticator](https://www.yubico.com/products/yubico-authenticator/).

The YubiKey can be set to be [pin-only](https://docs.yubico.com/yesdk/users-manual/application-piv/pin-puk-mgmt-key.html#pin-only).
This allows the PIN (6 to 8 bytes) to be used in lieu of the management key (32 bytes).
The shorter key has significant effects on security and usability.

The FIDO2 PIN can be set to a non-default value as well.

Sources:
- PIN, PUK, and Management Key [Yubico](https://docs.yubico.com/yesdk/users-manual/application-piv/pin-puk-mgmt-key.html)
- Securing SSH with FIDO2 [Yubico](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html)

## SSH

The setup recommended by Yubico:
```
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "your_email@example.com"
```

Command & Options:
- `ssh-keygen`: the command to generate the SSH key
- `-t ed25519-sk`: the type of key to create (Older devices cannot support `ed25519-sk`, in which case `ecdsa-sk` is the recommendation.)
- `-O resident`: stores the entire private key on the YubiKey (recoverable with `ssh-keygen -K`; requires a FIDO2 PIN)
- `-O application=ssh:<name>`: for resident keys stored on the YubiKey, differentiates between resident keys on the device
- `-O verify-required`: in addition to a touch on the YubiKey device, requires the FIDO2 PIN (or fingerprint) for use
- `-O no-touch-required`: disables the user presence requirement
- `-C "comment"`: helps to identify the key
- `-f <output_keyfile>`: specifies the the filepath to write (useful for multiple keys of the same type) 

Sources:
- Securing SSH with FIDO2 [Yubico](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html)

## Git

When diffs are short, it's nice to see them in the terminal.
```sh
git config --global --add core.pager "less -F -X"
```


Signing commits and tags is painless if `git` is configured to do it automatically. 
```sh
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

This requires a signing key.
If you already have a gpg key established, it's fine to use.
On the other hand, if you would need to learn gpg to set up a key, it's probably easier to just use SSH instead.

For a gpg key:
```sh
gpg --list-secret-keys --keyid-format=long    # to list your key id
git config --global user.signingkey <key id>
```

For an SSH key:
```sh
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/example_key.pub
```

Sources:
- Telling Git about your GPG key [GitHub](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-gpg-key)
- Telling Git about you SSH key [GitHub](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key#telling-git-about-your-ssh-key)

## Github

Under a few scenarios, you may need to update your SSH config to identify which key should be used for GitHub.
By default, SSH will use well-known key names.
If you specified a custom name for your keyfile, you would need to declare it.

In `~/.ssh/config`:
```ini
Host *.github.com
  IdentityFile ~/.ssh/custom_keyfile_name
  IdentityFile ~/.ssh/alternate_custom_keyfile_name
```

In the GitHub user account settings, you'll need to add the contents of the public key (i.e., `*.pub`).
SSH keys can be used for authentication and signing.

Once the authentication key has been added, the connection can be tested with:
```sh
ssh -T git@github.com
```

Sources:
- Generate new SSH key [GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key-for-a-hardware-security-key)
- Adding a new SSH key to your account [GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)
- Signing commits [GitHub](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
- Securing SSH with FIDO2 [Yubico](https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html)
