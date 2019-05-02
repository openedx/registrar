""" Constants for enrollments app """

PROGRAM_CACHE_KEY_TPL = 'program-{uuid}'

PROGRAM_ENROLLMENT_ENROLLED = 'enrolled'
PROGRAM_ENROLLMENT_PENDING = 'pending'
PROGRAM_ENROLLMENT_SUSPENDED = 'suspended'
PROGRAM_ENROLLMENT_CANCELED = 'canceled'

PROGRAM_ENROLLMENT_STATUSES = [
    PROGRAM_ENROLLMENT_ENROLLED,
    PROGRAM_ENROLLMENT_PENDING,
    PROGRAM_ENROLLMENT_SUSPENDED,
    PROGRAM_ENROLLMENT_CANCELED,
]

COURSE_ENROLLMENT_ACTIVE = 'active'
COURSE_ENROLLMENT_INACTIVE = 'inactive'

COURSE_ENROLLMENT_STATUSES = [
    COURSE_ENROLLMENT_ACTIVE,
    COURSE_ENROLLMENT_INACTIVE,
]
