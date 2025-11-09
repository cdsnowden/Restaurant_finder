# GitHub Pages Setup for Privacy Policy

This guide will help you host your privacy policy on GitHub Pages so Apple can access it during app review.

## Quick Overview

Your privacy policy will be available at:
**https://cdsnowden.github.io/Restaurant_finder/privacy-policy.html**

## Setup Instructions

### Step 1: Enable GitHub Pages on Your Repository

1. Go to your repository: https://github.com/cdsnowden/Restaurant_finder
2. Click **Settings** (top menu)
3. Scroll down to **Pages** (left sidebar)
4. Under **Source**:
   - Branch: Select **main** (or **master**)
   - Folder: Select **/ (root)**
5. Click **Save**
6. Wait 2-3 minutes for GitHub to deploy

### Step 2: Upload Privacy Policy HTML

The HTML version of your privacy policy has been created as `privacy-policy.html` in your project root.

Run these commands in Git Bash or Command Prompt:

```bash
cd C:\Users\chris\restaurant_finder
git add privacy-policy.html
git commit -m "Add privacy policy for App Store"
git push origin main
```

### Step 3: Verify It Works

After 2-3 minutes, visit:
https://cdsnowden.github.io/Restaurant_finder/privacy-policy.html

You should see your privacy policy displayed.

### Step 4: Use This URL in App Store Connect

When filling out your App Store listing, use this URL for the Privacy Policy field:
```
https://cdsnowden.github.io/Restaurant_finder/privacy-policy.html
```

## Alternative: Use GitHub Docs Folder (More Organized)

If you prefer to keep documentation separate:

```bash
# Create docs folder
mkdir docs
copy privacy-policy.html docs\

# Commit and push
git add docs/privacy-policy.html
git commit -m "Add privacy policy in docs folder"
git push origin main
```

Then in GitHub Settings > Pages:
- Branch: main
- Folder: **/docs**
- Save

Your URL will be:
https://cdsnowden.github.io/Restaurant_finder/privacy-policy.html

## Troubleshooting

**"404 - Page not found"**
- Wait 5-10 minutes (GitHub Pages can take time to deploy)
- Check that GitHub Pages is enabled in repository settings
- Make sure the file is pushed to your repository
- Verify the branch selected in Pages settings matches where you pushed

**"Repository not found"**
- Make sure your repository is **public** (not private)
- Go to Settings > General > scroll to bottom
- If private, click "Change visibility" > "Make public"

**"Changes not showing up"**
- Clear browser cache (Ctrl+Shift+R)
- Wait a few more minutes
- Check GitHub Actions tab for deployment status

## Testing Before Mac

Once you set this up, test the URL in your browser. If it works on Windows, it will work for Apple's review team!

---

**Next Steps After Setup:**
1. ✅ Privacy policy is publicly hosted
2. ✅ You have the URL for App Store Connect
3. ✅ Ready to proceed with iOS submission on Mac!
