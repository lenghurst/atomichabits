# Google Cloud Setup: Sherlock Sensors

> **Phase:** 46.3  
> **Purpose:** Authorize OAuth scopes for the "Sherlock Protocol" to detect behavioral patterns.  
> **Criticality:** Required to avoid "Unverified App" warnings and 403 Forbidden errors.

## 1. Enable Required APIs
Before scopes can be used, the underlying APIs must be enabled in the Google Cloud Console.

1. Go to **[APIs & Services > Enabled APIs & services](https://console.cloud.google.com/apis/dashboard)**
2. Click **+ ENABLE APIS AND SERVICES**
3. Enable the following APIs:
   - **Google Calendar API** (`calendar-json.googleapis.com`)
   - **YouTube Data API v3** (`youtube.googleapis.com`)
   - **Google Tasks API** (`tasks.googleapis.com`)
   - **Google Fitness API** (`fitness.googleapis.com`)
   - **People API** (`people.googleapis.com`)

## 2. Configure OAuth Consent Screen
Add the sensitive scopes to your app's configuration.

1. Go to **[APIs & Services > OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent)**
2. Click **Edit App**
3. Navigate to **Step 2: Scopes**
4. Click **ADD OR REMOVE SCOPES**
5. Paste the following URLs into "Manually add scopes":

```text
https://www.googleapis.com/auth/calendar.readonly
https://www.googleapis.com/auth/youtube.readonly
https://www.googleapis.com/auth/tasks.readonly
https://www.googleapis.com/auth/fitness.activity.read
https://www.googleapis.com/auth/user.birthday.read
```

6. Click **ADD TO TABLE** > **UPDATE** > **SAVE AND CONTINUE**

## 3. Verify Test Users
Until the app passes Google Verify (which requires a security audit for these scopes), you must list specific emails to allow testing.

1. Go to **[APIs & Services > OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent)**
2. Scroll to **Test users**
3. Ensure your development accounts are listed.

## 4. Verification
To verify the setup:
1. Run the app in debug mode.
2. Trigger the "Sherlock Scan" (or sign in if configured to ask immediately).
3. Ensure the Google permission dialog lists the specific permissions (Calendar, YouTube, etc.) without a red "This app is unverified" interstitial.
