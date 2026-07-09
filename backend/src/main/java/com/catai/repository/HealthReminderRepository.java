package com.catai.repository;

import com.catai.entity.HealthReminder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HealthReminderRepository extends JpaRepository<HealthReminder, String> {

    List<HealthReminder> findByPetIdOrderByDateAsc(String petId);

    List<HealthReminder> findByPetIdAndEnabledTrueAndDateLessThanEqualOrderByDateAsc(String petId, String date);

    List<HealthReminder> findByPetIdAndEnabledTrueAndDateBetweenOrderByDateAsc(String petId, String startDate, String endDate);

    void deleteByPetId(String petId);
}
