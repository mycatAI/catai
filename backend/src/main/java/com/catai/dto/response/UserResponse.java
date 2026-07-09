package com.catai.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {

    private String id;
    private String username;
    private String avatar;
    private String bio;
    private String phone;
    private String email;
    private String topics;
    private String joinDate;
    private String updateTime;
}
