package com.catai.service;

import com.catai.dto.request.HealthReminderRequest;
import com.catai.dto.response.HealthReminderResponse;
import com.catai.entity.HealthReminder;
import com.catai.entity.Pet;
import com.catai.exception.ResourceNotFoundException;
import com.catai.exception.UnauthorizedException;
import com.catai.repository.HealthReminderRepository;
import com.catai.repository.PetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HealthReminderService {

    private final HealthReminderRepository healthReminderRepository;
    private final PetRepository petRepository;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public List<HealthReminderResponse> getReminders(String petId, String userId) {
        verifyPetOwnership(petId, userId);
        return healthReminderRepository.findByPetIdOrderByDateAsc(petId).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    public List<HealthReminderResponse> getTodayReminders(String petId, String userId) {
        verifyPetOwnership(petId, userId);
        String today = LocalDate.now().format(DATE_FMT);
        return healthReminderRepository
                .findByPetIdAndEnabledTrueAndDateLessThanEqualOrderByDateAsc(petId, today).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    public List<HealthReminderResponse> getUpcomingReminders(String petId, String userId) {
        verifyPetOwnership(petId, userId);
        String today = LocalDate.now().format(DATE_FMT);
        String sevenDaysLater = LocalDate.now().plusDays(7).format(DATE_FMT);
        return healthReminderRepository
                .findByPetIdAndEnabledTrueAndDateBetweenOrderByDateAsc(petId, today, sevenDaysLater).stream()
                .map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public HealthReminderResponse createReminder(String petId, String userId, HealthReminderRequest req) {
        verifyPetOwnership(petId, userId);

        HealthReminder reminder = HealthReminder.builder()
                .id(UUID.randomUUID().toString())
                .petId(petId)
                .type(req.getType() != null ? req.getType() : "custom")
                .title(req.getTitle() != null ? req.getTitle() : "")
                .date(req.getDate() != null ? req.getDate() : "")
                .time(req.getTime() != null ? req.getTime() : "09:00")
                .repeatCycle(req.getRepeatCycle() != null ? req.getRepeatCycle() : "none")
                .enabled(req.getEnabled() != null ? req.getEnabled() : true)
                .notes(req.getNotes() != null ? req.getNotes() : "")
                .createTime(LocalDate.now().format(DATE_FMT))
                .build();

        healthReminderRepository.save(reminder);
        return toResponse(reminder);
    }

    @Transactional
    public HealthReminderResponse updateReminder(String reminderId, String userId, HealthReminderRequest req) {
        HealthReminder reminder = healthReminderRepository.findById(reminderId)
                .orElseThrow(() -> new ResourceNotFoundException("提醒", reminderId));
        verifyPetOwnership(reminder.getPetId(), userId);

        if (req.getType() != null) reminder.setType(req.getType());
        if (req.getTitle() != null) reminder.setTitle(req.getTitle());
        if (req.getDate() != null) reminder.setDate(req.getDate());
        if (req.getTime() != null) reminder.setTime(req.getTime());
        if (req.getRepeatCycle() != null) reminder.setRepeatCycle(req.getRepeatCycle());
        if (req.getEnabled() != null) reminder.setEnabled(req.getEnabled());
        if (req.getNotes() != null) reminder.setNotes(req.getNotes());

        healthReminderRepository.save(reminder);
        return toResponse(reminder);
    }

    @Transactional
    public void deleteReminder(String reminderId, String userId) {
        HealthReminder reminder = healthReminderRepository.findById(reminderId)
                .orElseThrow(() -> new ResourceNotFoundException("提醒", reminderId));
        verifyPetOwnership(reminder.getPetId(), userId);
        healthReminderRepository.delete(reminder);
    }

    private void verifyPetOwnership(String petId, String userId) {
        Pet pet = petRepository.findById(petId)
                .orElseThrow(() -> new ResourceNotFoundException("宠物", petId));
        if (!pet.getUserId().equals(userId)) {
            throw new UnauthorizedException("无权访问此宠物");
        }
    }

    private HealthReminderResponse toResponse(HealthReminder reminder) {
        return HealthReminderResponse.builder()
                .id(reminder.getId())
                .petId(reminder.getPetId())
                .type(reminder.getType())
                .title(reminder.getTitle())
                .date(reminder.getDate())
                .time(reminder.getTime())
                .repeatCycle(reminder.getRepeatCycle())
                .enabled(reminder.getEnabled())
                .notes(reminder.getNotes())
                .createTime(reminder.getCreateTime())
                .build();
    }
}
