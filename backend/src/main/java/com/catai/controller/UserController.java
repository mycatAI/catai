package com.catai.controller;

import com.catai.dto.request.UserProfileRequest;
import com.catai.dto.response.ApiResponse;
import com.catai.dto.response.UserResponse;
import com.catai.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(Authentication auth) {
        String userId = auth.getName();
        UserResponse user = userService.getCurrentUser(userId);
        return ResponseEntity.ok(ApiResponse.success(user));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(Authentication auth,
                                                                     @RequestBody UserProfileRequest req) {
        String userId = auth.getName();
        UserResponse user = userService.updateProfile(userId, req);
        return ResponseEntity.ok(ApiResponse.success(user));
    }
}
