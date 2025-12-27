import { Controller, Get, Post, Body, Param, Patch, Delete } from '@nestjs/common';
import { DriverService } from './driver.service';
import { Driver } from './driver.entity';

@Controller('driver')
export class DriverController {
    constructor(private readonly driverService: DriverService) { }

    @Get()
    findAll(): Promise<Driver[]> {
        return this.driverService.findAll();
    }

    @Get(':id')
    findOne(@Param('id') id: string): Promise<Driver> {
        return this.driverService.findOne(id);
    }

    @Post()
    create(@Body() data: Partial<Driver>): Promise<Driver> {
        return this.driverService.create(data);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() data: Partial<Driver>): Promise<Driver> {
        return this.driverService.update(id, data);
    }

    @Delete(':id')
    remove(@Param('id') id: string): Promise<void> {
        return this.driverService.remove(id);
    }
}
