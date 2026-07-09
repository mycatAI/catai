package com.catai.controller;

import com.catai.dto.request.FeedPostRequest;
import com.catai.dto.response.ApiResponse;
import com.catai.dto.response.FeedPostResponse;
import com.catai.service.FeedPostService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/feed")
@RequiredArgsConstructor
public class FeedPostController {

    private final FeedPostService feedPostService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<FeedPostResponse>>> getPosts(
            @RequestParam(required = false) String topicId) {
        List<FeedPostResponse> posts = feedPostService.getPosts(topicId);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<FeedPostResponse>>> getPostsByUser(@PathVariable String userId) {
        List<FeedPostResponse> posts = feedPostService.getPostsByUser(userId);
        return ResponseEntity.ok(ApiResponse.success(posts));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<FeedPostResponse>> createPost(@Valid @RequestBody FeedPostRequest req,
                                                                      Authentication auth) {
        String userId = auth.getName();
        FeedPostResponse post = feedPostService.createPost(userId, req);
        return ResponseEntity.ok(ApiResponse.success(post));
    }
}
