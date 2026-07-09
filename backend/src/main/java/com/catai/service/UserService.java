package com.catai.service;

import com.catai.dto.request.LoginRequest;
import com.catai.dto.request.RegisterRequest;
import com.catai.dto.request.UserProfileRequest;
import com.catai.dto.response.LoginResponse;
import com.catai.dto.response.UserResponse;
import com.catai.entity.User;
import com.catai.exception.ResourceNotFoundException;
import com.catai.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Transactional
    public LoginResponse register(RegisterRequest req) {
        if (userRepository.existsByUsername(req.getUsername())) {
            throw new RuntimeException("用户名已被注册");
        }

        String today = LocalDate.now().format(DATE_FMT);
        User user = User.builder()
                .id(UUID.randomUUID().toString())
                .username(req.getUsername())
                .password(passwordEncoder.encode(req.getPassword()))
                .avatar("")
                .bio("")
                .phone("")
                .email("")
                .topics("")
                .joinDate(today)
                .updateTime(today)
                .build();

        userRepository.save(user);

        String token = jwtService.generateToken(user.getId(), user.getUsername());
        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .avatar(user.getAvatar())
                .build();
    }

    public LoginResponse login(LoginRequest req) {
        User user = userRepository.findByUsername(req.getUsername())
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new RuntimeException("密码错误");
        }

        String token = jwtService.generateToken(user.getId(), user.getUsername());
        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .username(user.getUsername())
                .avatar(user.getAvatar())
                .build();
    }

    public UserResponse getCurrentUser(String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户", userId));
        return toResponse(user);
    }

    @Transactional
    public UserResponse updateProfile(String userId, UserProfileRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户", userId));

        if (req.getUsername() != null) user.setUsername(req.getUsername());
        if (req.getAvatar() != null) user.setAvatar(req.getAvatar());
        if (req.getBio() != null) user.setBio(req.getBio());
        if (req.getPhone() != null) user.setPhone(req.getPhone());
        if (req.getEmail() != null) user.setEmail(req.getEmail());
        if (req.getTopics() != null) user.setTopics(req.getTopics());
        user.setUpdateTime(LocalDate.now().format(DATE_FMT));

        userRepository.save(user);
        return toResponse(user);
    }

    public boolean checkUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .avatar(user.getAvatar())
                .bio(user.getBio())
                .phone(user.getPhone())
                .email(user.getEmail())
                .topics(user.getTopics())
                .joinDate(user.getJoinDate())
                .updateTime(user.getUpdateTime())
                .build();
    }
}
