import { Module } from '@nestjs/common';
import { LocationGateway } from './location.gateway';
import { NganyaModule } from '../nganya/nganya.module';
import { AuthModule } from '../auth/auth.module';

@Module({
    imports: [NganyaModule, AuthModule],
    providers: [LocationGateway],
})
export class LocationModule { }
