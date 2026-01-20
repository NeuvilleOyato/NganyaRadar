import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, JoinColumn, CreateDateColumn } from 'typeorm';
import { Nganya } from '../nganya/nganya.entity';

@Entity()
export class Review {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => Nganya, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'nganya_id' })
    nganya: Nganya;

    @Column()
    nganya_id: string;

    @Column('float')
    rating: number; // Overall average

    @Column('int', { default: 0 })
    rating_driver: number;

    @Column('int', { default: 0 })
    rating_music: number;

    @Column('int', { default: 0 })
    rating_design: number;

    @Column('int', { default: 0 })
    rating_crew: number;

    @Column({ nullable: true })
    comment: string; // Short comment

    @CreateDateColumn()
    created_at: Date;

    // Ideally, we'd have a user_id here too, but for MVP anonymity is allowed or simple device ID
    // @Column({ nullable: true })
    // user_identifier: string; 
}
