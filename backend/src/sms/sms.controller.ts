import { Controller, Post, Body } from '@nestjs/common';
import { SmsService } from './sms.service';

@Controller('sms')
export class SmsController {
    constructor(private readonly smsService: SmsService) { }

    // Simulating an endpoint that an SMS gateway (like Africa's Talking) would hit
    @Post('webhook')
    async handleIncomingSms(@Body() payload: { from: string; text: string }) {
        // Basic payload structure
        return this.smsService.processIncomingSms(payload.from, payload.text);
    }
}
