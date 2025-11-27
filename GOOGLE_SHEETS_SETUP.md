Do the steps in GOOGLE_CALENDAR_SETUP.md first to setup your Google Service Account and incorporate your API key into this project.

## Step 1: Enable Google Sheets API

**IMPORTANT**: This must be done in the same Google Cloud project where you enabled the Calendar API.

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Make sure you're in the same project where you set up the Calendar API
3. Click the hamburger menu (☰) in the top left
4. Go to **"APIs & Services"** > **"Library"**
5. In the search bar, type "Google Sheets API"
6. Click on **"Google Sheets API"** from the results
7. Click the **"Enable"** button
8. Wait for the API to be enabled (this may take a minute)

**Note**: If you get a "403 insufficient authentication scopes" error, this step was likely skipped or the API wasn't fully enabled.

## Step 2: Create a Google Sheet

1. Go to [Google Sheets](https://sheets.google.com/)
2. Create a new Google Sheet
3. Add header row in the first row: `Timestamp | Name | Contact | Feedback`
4. Note the Sheet ID from the URL:
   - The URL will look like: `https://docs.google.com/spreadsheets/d/SHEET_ID_HERE/edit`
   - Copy the long string between `/d/` and `/edit`

## Step 3: Share Sheet with Service Account

1. In your Google Sheet, click the **"Share"** button (top right)
2. In the "Add people and groups" field, paste your service account email
   - This is the `client_email` from your `google-calendar-service-account.json` file
   - It looks like: `your-service-account@your-project-id.iam.gserviceaccount.com`
3. Set the permission dropdown to **"Editor"** (needed to append rows)
4. Click **"Send"** (you may see a message saying the email won't receive a notification - that's normal for service accounts)

## Step 4: Configure in App

1. Open `petros-app/petros-app/Config/GoogleSheetsConfig.swift`
2. Replace `YOUR_SHEET_ID_HERE` with your actual Sheet ID from Step 2
3. The range should be `"Sheet1!A:D"` (or adjust if your sheet name is different)

## Troubleshooting

### "403 insufficient authentication scopes" error
- Make sure you enabled the Google Sheets API in Step 1
- It can take a few minutes for the API to be fully enabled
- Try waiting 2-3 minutes and submitting again

### "Permission denied" error
- Verify that you shared the sheet with the service account email (Step 3)
- Make sure the permission is set to "Editor" (not "Viewer")
- Double-check that you used the correct service account email from the JSON file
