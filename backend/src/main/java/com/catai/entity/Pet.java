package com.catai.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "pet_info")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Pet {

    @Id
    @Column(name = "id", length = 64)
    private String id;

    @Column(name = "user_id", length = 64, nullable = false)
    private String userId;

    @Column(name = "name", length = 100, nullable = false)
    private String name;

    @Column(name = "species", length = 50)
    private String species;

    @Column(name = "breed", length = 100)
    private String breed;

    @Column(name = "birth_date", length = 10)
    private String birthDate;

    @Column(name = "gender", length = 10)
    private String gender;

    @Column(name = "avatar", length = 500)
    private String avatar;

    @Column(name = "weight")
    private Double weight;

    @Column(name = "height")
    private Double height;

    @Column(name = "color", length = 50)
    private String color;

    @Column(name = "notes", length = 1000)
    private String notes;

    @Column(name = "create_time", length = 10)
    private String createTime;

    @Column(name = "update_time", length = 10)
    private String updateTime;
}
