package com.catai.controller;

import com.catai.dto.request.LoginRequest;
import com.catai.dto.request.RegisterRequest;
import com.catai.dto.response.ApiResponse;
import com.catai.dto.response.LoginResponse;
import com.catai.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<LoginResponse>> register(@Valid @RequestBody RegisterRequest req) {
        LoginResponse result = userService.register(req);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest req) {
        LoginResponse result = userService.login(req);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @GetMapping("/check-username")
    public ResponseEntity<ApiResponse<Boolean>> checkUsername(@RequestParam String username) {
        boolean exists = userService.checkUsername(username);
        return ResponseEntity.ok(ApiResponse.success(exists));
    }
}
