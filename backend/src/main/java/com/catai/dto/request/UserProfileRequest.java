package com.catai.dto.request;

import lombok.Data;

@Data
public class UserProfileRequest {

    private String username;
    private String avatar;
    private String bio;
    private String phone;
    private String email;
    private String topics;
}
