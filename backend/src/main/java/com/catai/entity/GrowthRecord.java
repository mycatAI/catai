package com.catai.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "growth_record")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GrowthRecord {

    @Id
    @Column(name = "id", length = 64)
    private String id;

    @Column(name = "pet_id", length = 64, nullable = false)
    private String petId;

    @Column(name = "date", length = 10)
    private String date;

    @Column(name = "weight")
    private Double weight;

    @Column(name = "height")
    private Double height;

    @Column(name = "photo", length = 500)
    private String photo;

    @Column(name = "notes", length = 1000)
    private String notes;

    @Column(name = "type", length = 20)
    private String type;

    @Column(name = "create_time", length = 10)
    private String createTime;
}
