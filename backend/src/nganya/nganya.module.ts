import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NganyaService } from './nganya.service';
import { NganyaController } from './nganya.controller';
import { Nganya } from './nganya.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Nganya])],
    providers: [NganyaService],
    controllers: [NganyaController],
    exports: [NganyaService],
})
export class NganyaModule { }
