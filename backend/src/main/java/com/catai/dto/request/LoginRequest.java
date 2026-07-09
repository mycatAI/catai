package com.catai.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LoginRequest {

    @NotBlank(message = "用户名不能为空")
    @Size(min = 2, message = "用户名至少2个字符")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 4, message = "密码至少4个字符")
    private String password;
}
