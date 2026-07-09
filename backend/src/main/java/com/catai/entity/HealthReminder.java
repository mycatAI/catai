package com.catai.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "health_reminder")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthReminder {

    @Id
    @Column(name = "id", length = 64)
    private String id;

    @Column(name = "pet_id", length = 64, nullable = false)
    private String petId;

    @Column(name = "type", length = 20)
    private String type;

    @Column(name = "title", length = 200)
    private String title;

    @Column(name = "date", length = 10)
    private String date;

    @Column(name = "time", length = 5)
    private String time;

    @Column(name = "repeat_cycle", length = 20)
    private String repeatCycle;

    @Column(name = "enabled")
    private Boolean enabled;

    @Column(name = "notes", length = 1000)
    private String notes;

    @Column(name = "create_time", length = 10)
    private String createTime;
}
