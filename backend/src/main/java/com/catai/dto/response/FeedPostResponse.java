package com.catai.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FeedPostResponse {

    private Long id;
    private String userId;
    private String topicId;
    private String content;
    private String author;
    private String avatar;
    private Integer likes;
    private Integer comments;
    private String createTime;
}
