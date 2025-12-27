import { Module } from '@nestjs/common';
import { SmsService } from './sms.service';
import { SmsController } from './sms.controller';
import { NganyaModule } from '../nganya/nganya.module';

@Module({
    imports: [NganyaModule],
    providers: [SmsService],
    controllers: [SmsController],
})
export class SmsModule { }
