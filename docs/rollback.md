# Rollback Procedure & Database Restoration Plan

This runbook outlines emergency procedures for rolling back backend code releases on Render and restoring database states from MongoDB Atlas point-in-time backups.

---

## 1. Emergency Code Rollback (Render)

If a deployment introduces a critical bug or breaking API regression:

### Option A: Render Dashboard Rollback (Instant)
1. Go to **Render Dashboard** → **Web Services** → `bus-system-backend-staging`.
2. Click the **Events** tab.
3. Locate the previous stable build commit.
4. Click **Rollback** next to the stable build. Render will redeploy that exact build artifact immediately.

### Option B: Git Revert (Repository Level)
1. Revert the problematic commit locally:
   ```bash
   git revert HEAD -m 1
   git push origin main
   ```
2. Render will automatically trigger continuous deployment for the revert commit.

---

## 2. MongoDB Atlas Database Restoration Plan

### Automatic Point-In-Time Restore (Atlas PITR)
MongoDB Atlas maintains continuous cloud backups for staging and production databases.

### Restoration Steps:
1. Log in to [MongoDB Atlas Console](https://cloud.mongodb.com/).
2. Select your project and cluster (`Cluster0`).
3. Click the **Backup** tab.
4. Select **Point-in-Time Restore**.
5. Choose a timestamp prior to the incident/corruption event.
6. Target Destination: Restore to a new temporary cluster (e.g., `cluster-restore-temp`).
7. Once restore completes, verify data integrity on `cluster-restore-temp`.
8. Update `MONGODB_URI` in Render environment variables to point to the restored cluster or swap connection strings.

---

## 3. Post-Rollback Safety Verification Checklist

After executing a code or database rollback, perform these safety checks:

1. [ ] Verify backend responds with `200 OK` on `https://<app>.onrender.com/health`.
2. [ ] Test passenger login endpoint (`POST /auth/login`).
3. [ ] Verify Chapa webhook URL accessibility (`POST /payments/webhook`).
4. [ ] Confirm MongoDB Atlas connection status and inspect application error logs.
