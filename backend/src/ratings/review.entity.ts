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

    @Column('int')
    rating: number; // 1-5

    @Column({ length: 280, nullable: true })
    comment: string; // Short comment

    @CreateDateColumn()
    created_at: Date;

    // Ideally, we'd have a user_id here too, but for MVP anonymity is allowed or simple device ID
    // @Column({ nullable: true })
    // user_identifier: string; 
}
