import { Controller, Get, Post, Body, Param, Patch, Delete } from '@nestjs/common';
import { NganyaService } from './nganya.service';
import { Nganya } from './nganya.entity';

@Controller('nganya')
export class NganyaController {
    constructor(private readonly nganyaService: NganyaService) { }

    @Get()
    findAll(): Promise<Nganya[]> {
        return this.nganyaService.findAll();
    }

    @Get(':id')
    findOne(@Param('id') id: string): Promise<Nganya> {
        return this.nganyaService.findOne(id);
    }

    @Post()
    create(@Body() data: Partial<Nganya>): Promise<Nganya> {
        return this.nganyaService.create(data);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() data: Partial<Nganya>): Promise<Nganya> {
        return this.nganyaService.update(id, data);
    }

    @Delete(':id')
    remove(@Param('id') id: string): Promise<void> {
        return this.nganyaService.remove(id);
    }
}
