import { Timestamp } from 'firebase-admin/firestore';

//  USER ROLES
export enum UserRole {
  ADMIN = 'admin',
  ORGANIZER = 'organizer',
  USER = 'user'
}

export interface UserClaims {
  admin?: boolean;
  organizer?: boolean;
  roles?: UserRole[];
}

//  EVENT TYPES 
export enum EventStatus {
  DRAFT = 'draft',
  PENDING_APPROVAL = 'pending_approval',
  APPROVED = 'approved',
  PUBLISHED = 'published',
  CANCELLED = 'cancelled',
  COMPLETED = 'completed'
}

export interface EventRequest {
  id?: string;
  eventTitle: string;
  eventDescription: string;
  eventDate: string; 
  location: string;
  organizerName: string;
  organizerEmail: string;
  organizerPhone?: string;
  expectedAttendees?: number;
  eventType?: string;
  status: EventStatus;
  requestedAt: Timestamp;
  updatedAt: Timestamp;
  assignedOrganizerUid?: string;
  assignedOrganizerEmail?: string;
  approvedBy?: string;
  approvedAt?: Timestamp;
  rejectionReason?: string;
}

export interface Event {
  id?: string;
  eventTitle: string;
  eventDescription: string;
  eventDate: string;
  location: string;
  organizerUid: string;
  organizerName: string;
  organizerEmail: string;
  organizerPhone?: string;
  expectedAttendees?: number;
  eventType?: string;
  status: EventStatus;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  publishedAt?: Timestamp;
  approvedBy?: string;
  approvedAt?: Timestamp;
  isActive: boolean;
  tags?: string[];
  imageUrl?: string;
}

// ZONE TYPES 
export interface Zone {
  id?: string;
  eventId: string;
  title: string;
  description?: string;
  capacity?: number;
  location?: string;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  createdBy: string;
  order?: number;
}

//  TRACK TYPES 
export interface Track {
  id?: string;
  eventId: string;
  zoneId: string;
  title: string;
  description?: string;
  capacity?: number;
  trackType?: string;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  createdBy: string;
  order?: number;
}

//  SESSION TYPES 
export interface Session {
  id?: string;
  eventId: string;
  zoneId: string;
  trackId: string;
  title: string;
  description?: string;
  speakerName?: string;
  speakerBio?: string;
  startTime: string; // ISO datetime string
  endTime: string; // ISO datetime string
  capacity?: number;
  sessionType?: string;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  createdBy: string;
  tags?: string[];
}

//  STALL TYPES 
export interface Stall {
  id?: string;
  eventId: string;
  zoneId: string;
  stallNumber: string;
  stallName: string;
  description?: string;
  vendorName?: string;
  vendorContact?: string;
  vendorEmail?: string;
  stallType?: string;
  size?: string;
  price?: number;
  isBooked: boolean;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  createdBy: string;
  bookedBy?: string;
  bookedAt?: Timestamp;
}

// REQUEST/RESPONSE TYPES 
export interface CreateEventRequestData {
  eventTitle: string;
  eventDescription: string;
  eventDate: string;
  location: string;
  organizerName: string;
  organizerEmail: string;
  organizerPhone?: string;
  expectedAttendees?: number;
  eventType?: string;
}

export interface UpdateEventStatusData {
  eventId: string;
  status: EventStatus;
  rejectionReason?: string;
}

export interface AssignOrganizerData {
  requestId: string;
  organizerUid: string;
  organizerEmail: string;
}

export interface CreateZoneData {
  eventId: string;
  title: string;
  description?: string;
  capacity?: number;
  location?: string;
  order?: number;
}

export interface CreateTrackData {
  eventId: string;
  zoneId: string;
  title: string;
  description?: string;
  capacity?: number;
  trackType?: string;
  order?: number;
}

export interface CreateSessionData {
  eventId: string;
  zoneId: string;
  trackId: string;
  title: string;
  description?: string;
  speakerName?: string;
  speakerBio?: string;
  startTime: string;
  endTime: string;
  capacity?: number;
  sessionType?: string;
  tags?: string[];
}

export interface CreateStallData {
  eventId: string;
  zoneId: string;
  stallNumber: string;
  stallName: string;
  description?: string;
  vendorName?: string;
  vendorContact?: string;
  vendorEmail?: string;
  stallType?: string;
  size?: string;
  price?: number;
}

// RESPONSE TYPES 
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination?: {
    page: number;
    limit: number;
    total: number;
    hasMore: boolean;
  };
}

//  VALIDATION TYPES 
export interface ValidationError {
  field: string;
  message: string;
}

export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
}

//  AUDIT TYPES 
export interface AuditLog {
  id?: string;
  userId: string;
  userEmail: string;
  action: string;
  resource: string;
  resourceId: string;
  details?: any;
  timestamp: Timestamp;
  ipAddress?: string;
  userAgent?: string;
}

//  NOTIFICATION TYPES
export interface Notification {
  id?: string;
  userId: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  isRead: boolean;
  createdAt: Timestamp;
  data?: any;
}
