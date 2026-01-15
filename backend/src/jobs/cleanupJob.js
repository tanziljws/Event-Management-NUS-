const cron = require('node-cron');
const fs = require('fs');
const path = require('path');
const logger = require('../config/logger');

// Configuration
const INVOICE_Retention_DAYS = 30; // Keep invoices for 30 days
const TEMP_UPLOAD_RETENTION_HOURS = 24; // Keep temp uploads for 24 hours

class CleanupJob {
    constructor() {
        this.invoiceDir = path.join(__dirname, '../../uploads/invoices');
        this.tempDir = path.join(__dirname, '../../uploads/temp'); // Example if exists
    }

    start() {
        // Run every day at 03:00 AM
        cron.schedule('0 3 * * *', async () => {
            logger.info('🧹 STARTING DAILY CLEANUP JOB');
            await this.cleanupInvoices();
            logger.info('✅ DAILY CLEANUP JOB COMPLETED');
        });

        logger.info('Initializing Cleanup Job (Scheduled: Daily at 03:00 AM)');
    }

    async cleanupInvoices() {
        try {
            if (!fs.existsSync(this.invoiceDir)) return;

            const files = await fs.promises.readdir(this.invoiceDir);
            const now = Date.now();
            let deletedCount = 0;

            for (const file of files) {
                if (!file.endsWith('.pdf')) continue;

                const filePath = path.join(this.invoiceDir, file);
                const stats = await fs.promises.stat(filePath);
                const ageInDays = (now - stats.mtimeMs) / (1000 * 60 * 60 * 24);

                if (ageInDays > INVOICE_Retention_DAYS) {
                    await fs.promises.unlink(filePath);
                    deletedCount++;
                }
            }

            if (deletedCount > 0) {
                logger.info(`🗑️  Cleaned up ${deletedCount} old invoice files older than ${INVOICE_Retention_DAYS} days`);
            }
        } catch (error) {
            logger.error('Error during invoice cleanup:', error);
        }
    }
}

module.exports = new CleanupJob();
