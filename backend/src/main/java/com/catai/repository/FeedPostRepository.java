package com.catai.repository;

import com.catai.entity.FeedPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FeedPostRepository extends JpaRepository<FeedPost, Long> {

    List<FeedPost> findByTopicIdOrderByLikesDesc(String topicId);

    List<FeedPost> findAllByOrderByLikesDesc();

    List<FeedPost> findByUserIdOrderByCreateTimeDesc(String userId);
}
