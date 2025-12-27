import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { Nganya } from './nganya/nganya.entity';
import { Driver } from './driver/driver.entity';

import { NganyaModule } from './nganya/nganya.module';
import { DriverModule } from './driver/driver.module';
import { AuthModule } from './auth/auth.module';
import { LocationModule } from './location/location.module';
import { SmsModule } from './sms/sms.module';
import { RatingsModule } from './ratings/ratings.module';
import { Review } from './ratings/review.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('POSTGRES_HOST'),
        port: configService.get<number>('POSTGRES_PORT'),
        username: configService.get<string>('POSTGRES_USER'),
        password: configService.get<string>('POSTGRES_PASSWORD'),
        database: configService.get<string>('POSTGRES_DB'),
        entities: [Nganya, Driver, Review],
        synchronize: true, // Only for development!
      }),
      inject: [ConfigService],
    }),
    NganyaModule,
    DriverModule,
    AuthModule,
    LocationModule,
    SmsModule,
    RatingsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
