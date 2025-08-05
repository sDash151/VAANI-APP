import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import logger from '../utils/logger.js';

class MLService {
    constructor() {
        this.mlServiceUrl = process.env.ML_SERVICE_URL || 'http://localhost:8000';
        this.client = axios.create({
            baseURL: this.mlServiceUrl,
            timeout: 30000, // 30 seconds timeout for video processing
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        });
    }

    /**
     * Process video file for ISL translation
     * @param {string} videoPath - Path to the video file
     * @returns {Promise<Object>} Translation result
     */
    async translateVideo(videoPath) {
        try {
            logger.info(`Processing video: ${videoPath}`);
            
            const formData = new FormData();
            formData.append('file', fs.createReadStream(videoPath));
            
            const response = await this.client.post('/predict/video', formData, {
                headers: {
                    ...formData.getHeaders()
                }
            });
            
            logger.info('Video translation completed successfully');
            return {
                success: true,
                data: response.data
            };
        } catch (error) {
            logger.error('Video translation failed:', error.message);
            return {
                success: false,
                error: error.response?.data?.error || error.message
            };
        }
    }

    /**
     * Check ML service health
     * @returns {Promise<boolean>} Service health status
     */
    async checkHealth() {
        try {
            const response = await this.client.get('/health');
            return response.status === 200;
        } catch (error) {
            logger.error('ML service health check failed:', error.message);
            return false;
        }
    }

    /**
     * Get ML service status
     * @returns {Promise<Object>} Service status information
     */
    async getStatus() {
        try {
            const response = await this.client.get('/status');
            return {
                success: true,
                data: response.data
            };
        } catch (error) {
            logger.error('Failed to get ML service status:', error.message);
            return {
                success: false,
                error: error.message
            };
        }
    }
}

export default new MLService(); 