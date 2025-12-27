import { Entity, Column, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

@Entity()
export class Nganya {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    name: string;

    @Column({ nullable: true })
    route_description: string;

    @Column('decimal', { precision: 10, scale: 2, default: 0 })
    current_fare: number;

    @Column({ default: false })
    is_active: boolean;

    @Column('double precision', { nullable: true })
    last_latitude: number;

    @Column('double precision', { nullable: true })
    last_longitude: number;

    @UpdateDateColumn()
    last_updated: Date;
}
