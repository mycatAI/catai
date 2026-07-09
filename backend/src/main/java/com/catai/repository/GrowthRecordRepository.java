package com.catai.repository;

import com.catai.entity.GrowthRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GrowthRecordRepository extends JpaRepository<GrowthRecord, String> {

    List<GrowthRecord> findByPetIdOrderByDateDesc(String petId);

    List<GrowthRecord> findByPetIdAndTypeOrderByDateDesc(String petId, String type);

    void deleteByPetId(String petId);
}
