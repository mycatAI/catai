package com.catai.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "feed_post")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FeedPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", length = 64, nullable = false)
    private String userId;

    @Column(name = "topic_id", length = 50)
    private String topicId;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "author", length = 100)
    private String author;

    @Column(name = "avatar", length = 500)
    private String avatar;

    @Column(name = "likes")
    @Builder.Default
    private Integer likes = 0;

    @Column(name = "comments")
    @Builder.Default
    private Integer comments = 0;

    @Column(name = "create_time", length = 10)
    private String createTime;
}
