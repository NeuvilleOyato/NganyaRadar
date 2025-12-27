import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DriverService } from './driver.service';
import { DriverController } from './driver.controller';
import { Driver } from './driver.entity';
import { NganyaModule } from '../nganya/nganya.module';

@Module({
    imports: [TypeOrmModule.forFeature([Driver]), NganyaModule],
    providers: [DriverService],
    controllers: [DriverController],
    exports: [DriverService],
})
export class DriverModule { }
