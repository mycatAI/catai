package com.catai.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "user_info")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @Column(name = "id", length = 64)
    private String id;

    @Column(name = "username", length = 100, unique = true, nullable = false)
    private String username;

    @Column(name = "password", length = 255, nullable = false)
    private String password;

    @Column(name = "avatar", length = 500)
    private String avatar;

    @Column(name = "bio", length = 500)
    private String bio;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "email", length = 200)
    private String email;

    @Column(name = "topics", length = 1000)
    private String topics;

    @Column(name = "join_date", length = 10)
    private String joinDate;

    @Column(name = "update_time", length = 10)
    private String updateTime;
}
