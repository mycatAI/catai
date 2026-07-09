package com.catai.repository;

import com.catai.entity.Pet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PetRepository extends JpaRepository<Pet, String> {

    List<Pet> findByUserIdOrderByUpdateTimeDesc(String userId);

    Optional<Pet> findByIdAndUserId(String id, String userId);

    void deleteByIdAndUserId(String id, String userId);
}
