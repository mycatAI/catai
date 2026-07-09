package com.catai.service;

import com.catai.dto.request.FeedPostRequest;
import com.catai.dto.response.FeedPostResponse;
import com.catai.entity.FeedPost;
import com.catai.entity.User;
import com.catai.exception.ResourceNotFoundException;
import com.catai.repository.FeedPostRepository;
import com.catai.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FeedPostService {

    private final FeedPostRepository feedPostRepository;
    private final UserRepository userRepository;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public List<FeedPostResponse> getPosts(String topicId) {
        List<FeedPost> posts;
        if (topicId != null && !topicId.isEmpty()) {
            posts = feedPostRepository.findByTopicIdOrderByLikesDesc(topicId);
        } else {
            posts = feedPostRepository.findAllByOrderByLikesDesc();
        }
        return posts.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<FeedPostResponse> getPostsByUser(String userId) {
        return feedPostRepository.findByUserIdOrderByCreateTimeDesc(userId).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public FeedPostResponse createPost(String userId, FeedPostRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("用户", userId));

        FeedPost post = FeedPost.builder()
                .userId(userId)
                .topicId(req.getTopicId() != null ? req.getTopicId() : "")
                .content(req.getContent())
                .author(user.getUsername())
                .avatar(user.getAvatar())
                .likes(0)
                .comments(0)
                .createTime(LocalDate.now().format(DATE_FMT))
                .build();

        feedPostRepository.save(post);
        return toResponse(post);
    }

    private FeedPostResponse toResponse(FeedPost post) {
        return FeedPostResponse.builder()
                .id(post.getId())
                .userId(post.getUserId())
                .topicId(post.getTopicId())
                .content(post.getContent())
                .author(post.getAuthor())
                .avatar(post.getAvatar())
                .likes(post.getLikes())
                .comments(post.getComments())
                .createTime(post.getCreateTime())
                .build();
    }
}
