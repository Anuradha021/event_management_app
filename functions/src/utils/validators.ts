
export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}


export interface EventData {
  title: string;
  description?: string;
  startDate: string; 
  endDate: string;   
  location?: string;
  maxAttendees?: number;
  isPublic?: boolean;
  tags?: string[];
}


export interface ZoneData {
  title: string;
  description?: string;
  capacity?: number;
  location?: string;
}


export interface TrackData {
  title: string;
  description?: string;
  color?: string;
  maxSessions?: number;
}

export interface SessionData {
  title: string;
  description?: string;
  speaker?: string;
  startTime: string; 
  endTime: string;   
  maxAttendees?: number;
}

// Stall data interface
export interface StallData {
  name: string;
  description?: string;
  category?: string;
  contactInfo?: {
    email?: string;
    phone?: string;
  };
}

export function validateEventData(data: any): ValidationResult {
  const errors: string[] = [];


  if (!data.title || typeof data.title !== 'string' || data.title.trim().length === 0) {
    errors.push("Title is required and must be a non-empty string");
  }

  if (!data.startDate || typeof data.startDate !== 'string') {
    errors.push("Start date is required and must be a valid date string");
  } else {
    const startDate = new Date(data.startDate);
    if (isNaN(startDate.getTime())) {
      errors.push("Start date must be a valid date");
    }
  }

  if (!data.endDate || typeof data.endDate !== 'string') {
    errors.push("End date is required and must be a valid date string");
  } else {
    const endDate = new Date(data.endDate);
    if (isNaN(endDate.getTime())) {
      errors.push("End date must be a valid date");
    }
    
    // Check if end date is after start date
    if (data.startDate) {
      const startDate = new Date(data.startDate);
      if (!isNaN(startDate.getTime()) && endDate <= startDate) {
        errors.push("End date must be after start date");
      }
    }
  }

  // Optional field validations
  if (data.description && typeof data.description !== 'string') {
    errors.push("Description must be a string");
  }

  if (data.location && typeof data.location !== 'string') {
    errors.push("Location must be a string");
  }

  if (data.maxAttendees && (!Number.isInteger(data.maxAttendees) || data.maxAttendees <= 0)) {
    errors.push("Max attendees must be a positive integer");
  }

  if (data.isPublic && typeof data.isPublic !== 'boolean') {
    errors.push("isPublic must be a boolean");
  }

  if (data.tags && (!Array.isArray(data.tags) || !data.tags.every((tag: any) => typeof tag === 'string'))) {
    errors.push("Tags must be an array of strings");
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}


export function validateZoneData(data: any): ValidationResult {
  const errors: string[] = [];

  // Required fields
  if (!data.title || typeof data.title !== 'string' || data.title.trim().length === 0) {
    errors.push("Title is required and must be a non-empty string");
  }


  if (data.description && typeof data.description !== 'string') {
    errors.push("Description must be a string");
  }

  if (data.capacity && (!Number.isInteger(data.capacity) || data.capacity <= 0)) {
    errors.push("Capacity must be a positive integer");
  }

  if (data.location && typeof data.location !== 'string') {
    errors.push("Location must be a string");
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}


export function validateTrackData(data: any): ValidationResult {
  const errors: string[] = [];

  // Required fields
  if (!data.title || typeof data.title !== 'string' || data.title.trim().length === 0) {
    errors.push("Title is required and must be a non-empty string");
  }


  if (data.description && typeof data.description !== 'string') {
    errors.push("Description must be a string");
  }

  if (data.color && (typeof data.color !== 'string' || !/^#[0-9A-F]{6}$/i.test(data.color))) {
    errors.push("Color must be a valid hex color code");
  }

  if (data.maxSessions && (!Number.isInteger(data.maxSessions) || data.maxSessions <= 0)) {
    errors.push("Max sessions must be a positive integer");
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}


export function validateSessionData(data: any): ValidationResult {
  const errors: string[] = [];

  // Required fields
  if (!data.title || typeof data.title !== 'string' || data.title.trim().length === 0) {
    errors.push("Title is required and must be a non-empty string");
  }

  if (!data.startTime || typeof data.startTime !== 'string') {
    errors.push("Start time is required and must be a valid date string");
  } else {
    const startTime = new Date(data.startTime);
    if (isNaN(startTime.getTime())) {
      errors.push("Start time must be a valid date");
    }
  }

  if (!data.endTime || typeof data.endTime !== 'string') {
    errors.push("End time is required and must be a valid date string");
  } else {
    const endTime = new Date(data.endTime);
    if (isNaN(endTime.getTime())) {
      errors.push("End time must be a valid date");
    }
    
    // Check if end time is after start time
    if (data.startTime) {
      const startTime = new Date(data.startTime);
      if (!isNaN(startTime.getTime()) && endTime <= startTime) {
        errors.push("End time must be after start time");
      }
    }
  }

 
  if (data.description && typeof data.description !== 'string') {
    errors.push("Description must be a string");
  }

  if (data.speaker && typeof data.speaker !== 'string') {
    errors.push("Speaker must be a string");
  }

  if (data.maxAttendees && (!Number.isInteger(data.maxAttendees) || data.maxAttendees <= 0)) {
    errors.push("Max attendees must be a positive integer");
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}


export function validateStallData(data: any): ValidationResult {
  const errors: string[] = [];

  // Required fields
  if (!data.name || typeof data.name !== 'string' || data.name.trim().length === 0) {
    errors.push("Name is required and must be a non-empty string");
  }

  if (data.description && typeof data.description !== 'string') {
    errors.push("Description must be a string");
  }

  if (data.category && typeof data.category !== 'string') {
    errors.push("Category must be a string");
  }

  if (data.contactInfo) {
    if (typeof data.contactInfo !== 'object') {
      errors.push("Contact info must be an object");
    } else {
      if (data.contactInfo.email && (typeof data.contactInfo.email !== 'string' || !isValidEmail(data.contactInfo.email))) {
        errors.push("Contact email must be a valid email address");
      }
      
      if (data.contactInfo.phone && typeof data.contactInfo.phone !== 'string') {
        errors.push("Contact phone must be a string");
      }
    }
  }

  return {
    isValid: errors.length === 0,
    errors
  };
}


function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function sanitizeString(input: string): string {
  return input.trim().replace(/[<>]/g, '');
}


export function sanitizeData(data: any): any {
  const sanitized = { ...data };
  
  for (const key in sanitized) {
    if (typeof sanitized[key] === 'string') {
      sanitized[key] = sanitizeString(sanitized[key]);
    }
  }
  
  return sanitized;
}
