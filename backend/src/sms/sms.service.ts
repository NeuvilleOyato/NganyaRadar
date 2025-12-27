import { Injectable, BadRequestException } from '@nestjs/common';
import { NganyaService } from '../nganya/nganya.service';

@Injectable()
export class SmsService {
    constructor(private readonly nganyaService: NganyaService) { }

    async processIncomingSms(sender: string, message: string): Promise<any> {
        // Expected format: NG123|StageName|Fare
        // Example: NG-77282|CBD|50
        const parts = message.split('|');

        if (parts.length < 2) {
            throw new BadRequestException('Invalid SMS format. Expected: ID|Location|Fare(optional)');
        }

        // In a real app, we'd map "NG123" to a UUID or use the UUID directly.
        // For MVP, assuming the ID passed is the UUID or a recognizable short code.
        // Let's assume validation happens here.

        // To minimize data, we might maps short codes to UUIDs in DB.
        // implementing a simple direct update for now.

        const nganyaId = parts[0].trim();
        // const locationName = parts[1].trim(); // We might geocode this or just store it as "last_location_description"
        // const fare = parts[2] ? parseFloat(parts[2].trim()) : null;

        // NOTE: Our Nganya entity has last_latitude/longitude. 
        // If we only get text location, we might need a "last_location_text" field or dummy coords.
        // For MVP, if it's text, we currently can't store it in lat/long columns easily without changes.
        // Let's assume we just update 'route_description' or we add a text location field.
        // Re-reading SRS: "Backend parses SMS and updates nganya status". "Text-based route and stage names".

        // I should probably add `last_location_text` to Nganya entity to support this fully.
        // For now, I will update what I can.

        try {
            // Logic to find Nganya by ID or ShortCode
            const nganya = await this.nganyaService.findOne(nganyaId);

            const updateData: any = {
                last_updated: new Date(),
                // route_description: `At ${locationName}`, // Simple hack for now
            };

            if (parts[1]) {
                updateData.route_description = `At ${parts[1].trim()}`;
            }

            if (parts[2]) {
                updateData.current_fare = parseFloat(parts[2].trim());
            }

            await this.nganyaService.update(nganya.id, updateData);

            return { status: 'success', message: 'Nganya updated via SMS' };
        } catch (e) {
            console.error('SMS Processing Error', e);
            throw new BadRequestException('Failed to process SMS update'); // Don't leak details
        }
    }
}
