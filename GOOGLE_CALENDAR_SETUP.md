# Google Calendar API Setup Guide

This guide walks you through setting up Google Calendar API access for your Swift app using a service account.

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. If you don't have a Google account, sign in with your Google account
3. Click the project dropdown at the top (next to "Google Cloud")
4. Click **"New Project"**
5. Enter a project name (e.g., "petros-app-calendar")
6. Optionally select an organization (you can leave this as is)
7. Click **"Create"**
8. Wait for the project to be created (you'll see a notification)
9. Make sure the new project is selected in the project dropdown

## Step 2: Enable Google Calendar API

1. In the Google Cloud Console, click the hamburger menu (☰) in the top left
2. Go to **"APIs & Services"** > **"Library"**
3. In the search bar, type "Google Calendar API"
4. Click on **"Google Calendar API"** from the results
5. Click the **"Enable"** button
6. Wait for the API to be enabled (this may take a minute)

## Step 3: Create a Service Account

1. In the Google Cloud Console, go to **"APIs & Services"** > **"Credentials"** (or use the hamburger menu)
2. Click **"+ Create Credentials"** at the top
3. Select **"Service account"**
4. Fill in the service account details:
   - **Service account name**: `petros-app-calendar-service` (or any name you prefer)
   - **Service account ID**: This will auto-populate based on the name
   - **Description**: (Optional) "Service account for Petros app calendar access"
5. Click **"Create and Continue"**
6. Skip the optional steps (Grant this service account access to project, Grant users access to this service account) - you can click **"Continue"** or **"Done"**
7. You should now see your service account in the credentials list

## Step 4: Create and Download Service Account Key (JSON)

1. In the **"Credentials"** page, find your service account in the list
2. Click on the service account email (it will look like: `petros-app-calendar-service@your-project-id.iam.gserviceaccount.com`)
3. Go to the **"Keys"** tab
4. Click **"Add Key"** > **"Create new key"**
5. Select **"JSON"** as the key type
6. Click **"Create"**
7. A JSON file will automatically download to your computer
8. **Important**: Save this file securely! It contains sensitive credentials.
9. **Rename the file** to something like `google-calendar-service-account.json` for easier identification
10. Move it to a secure location (you'll add it to your Xcode project later)

## Step 5: Get Your Service Account Email

1. Open the downloaded JSON file in a text editor
2. Find the `client_email` field - it will look like: `"client_email": "petros-app-calendar-service@your-project-id.iam.gserviceaccount.com"`
3. Copy this email address - you'll need it in the next step

## Step 6: Share Your Google Calendar with the Service Account

1. Open [Google Calendar](https://calendar.google.com/) in your browser
2. Make sure you're signed in with the Google account that owns the calendar you want to use
3. On the left sidebar, find the calendar you want to share
4. Hover over the calendar name and click the three dots (⋯) that appear
5. Select **"Settings and sharing"**
6. Scroll down to the **"Share with specific people or groups"** section
7. Click **"Add people and groups"**
8. In the text field, paste the service account email (the one from Step 5)
9. Click on the permission dropdown next to the email field
10. Select **"See all event details"** (this gives read-only access, which is what you need)
11. Click **"Send"** (Note: You might see a message saying the email won't receive a notification - that's normal for service accounts)
12. The service account should now appear in the "Share with specific people or groups" list

## Step 7: Get Your Calendar ID

1. Still in the Google Calendar settings page (from Step 6)
2. Scroll down to the **"Integrate calendar"** section
3. You'll see a **"Calendar ID"** field
4. Copy this Calendar ID - it will be one of:
   - Your email address (if using your primary calendar)
   - A long string like `c_xxxxxxxxxxxxxxxxxxxxxxxxxx@group.calendar.google.com` (if using a secondary calendar)
   - Or just `primary` (this is an alias for your primary calendar)
5. **Note**: For your personal calendar, you can usually just use `"primary"` as the calendar ID in your code

## Step 8: Verify Your Setup

To verify everything is set up correctly:

1. ✅ Google Cloud project created
2. ✅ Google Calendar API enabled
3. ✅ Service account created
4. ✅ JSON key file downloaded
5. ✅ Calendar shared with service account email
6. ✅ Calendar ID noted

## Next Steps

Once you've completed these steps, you're ready to:
1. Add the JSON key file to your Xcode project (we'll do this securely)
2. Implement the authentication and API client code
3. Test the integration

## Important Security Notes

- **Never commit the JSON key file to git** - it contains sensitive credentials
- The JSON key file will be added to `.gitignore` to prevent accidental commits
- Keep the JSON file secure and don't share it publicly
- If the key is ever compromised, you can delete it in Google Cloud Console and create a new one

## Troubleshooting

### "API not enabled" error
- Make sure you enabled the Google Calendar API in Step 2
- It can take a few minutes for the API to be fully enabled

### "Permission denied" error
- Verify that you shared the calendar with the service account email (Step 6)
- Make sure you used the correct service account email from the JSON file
- Check that the calendar sharing permissions are set to at least "See all event details"

### "Calendar not found" error
- Verify the Calendar ID is correct
- Try using `"primary"` if you're using your main calendar
- Make sure the calendar is shared with the service account

### Can't find the service account email
- Open the downloaded JSON file
- Look for the `client_email` field - that's your service account email

## What's in the JSON Key File?

The JSON file contains:
- `type`: "service_account"
- `project_id`: Your Google Cloud project ID
- `private_key_id`: Unique identifier for the key
- `private_key`: The private key (keep this secret!)
- `client_email`: The service account email (this is what you share the calendar with)
- `client_id`: Client ID for the service account
- `auth_uri`: OAuth 2.0 authorization endpoint
- `token_uri`: OAuth 2.0 token endpoint
- `auth_provider_x509_cert_url`: Provider certificate URL
- `client_x509_cert_url`: Client certificate URL

You'll use this file in your Swift app to authenticate API requests.

