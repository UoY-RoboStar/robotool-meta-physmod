#define _POSIX_C_SOURCE 200112L

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <math.h>
#include <string.h>
#include <pthread.h>
#include <time.h>
#include <ctype.h>
#include "dmodel_interface.h"

// Forward declaration of AcrobotSensorState struct (actual definition generated later)
struct AcrobotSensorState {
    float shoulderAngle;
    float shoulderVelocity;
    float elbowAngle;
    float elbowVelocity;
};

#define DEBUG

#ifdef DEBUG
# define DPRINTF(arg) printf arg
#else
# define DPRINTF(arg)
#endif

#define err_abort(code,text) do { \
	fprintf(stderr, "%s at \"%s\":%d: %s\n", \
		text, __FILE__, __LINE__, strerror(code)); \
	abort(); \
	} while(0)
	
#define errno_abort(text) do { \
	fprintf(stderr, "%s at \"%s\":%d: %s\n", \
		text, __FILE__, __LINE__, strerror(errno)); \
	abort(); \
	} while (0)


// Temporary solution to trim strings taken from http://www.martinbroadhurst.com/trim-a-string-in-c.html 

char *ltrim(char *str, const char *seps)
{
    size_t totrim;
    if (seps == NULL) {
        seps = "\t\n\v\f\r ";
    }
    totrim = strspn(str, seps);
    if (totrim > 0) {
        size_t len = strlen(str);
        if (totrim == len) {
            str[0] = '\0';
        }
        else {
            memmove(str, str + totrim, len + 1 - totrim);
        }
    }
    return str;
}

char *rtrim(char *str, const char *seps)
{
    int i;
    if (seps == NULL) {
        seps = "\t\n\v\f\r ";
    }
    i = strlen(str) - 1;
    while (i >= 0 && strchr(seps, str[i]) != NULL) {
        str[i] = '\0';
        i--;
    }
    return str;
}

char *trim(char *str, const char *seps)
{
    return ltrim(rtrim(str, seps), seps);
}

char* concat(char *str1, char *str2) {
    char* result = calloc((strlen(str1)+strlen(str2))+1,sizeof(char));
    char* s1 = (char*)memcpy(result, str1, strlen(str1));
    char* s2 = (char*)memcpy(result+strlen(str1), str2, strlen(str2)); //strcat(result, str2);
    return result;
}

#define MAX_SEQ_SIZE 32
#define MAXQUEUE 32


FILE* log_file;






/* Representation of enum STATUS */

typedef enum {
	STATUS_ENTER_STATE,
	STATUS_ENTER_CHILDREN,
	STATUS_EXECUTE_STATE,
	STATUS_EXIT_CHILDREN,
	STATUS_EXIT_STATE,
	STATUS_INACTIVE,
} STATUS_Type;

typedef union {
} STATUS_Data;

typedef struct {
	STATUS_Type type;
	STATUS_Data data;
} STATUS_Enum;

STATUS_Enum create_STATUS_ENTER_STATE() {
	STATUS_Data data;

	STATUS_Type type = STATUS_ENTER_STATE;
	
	STATUS_Enum aux = (STATUS_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATUS_Enum create_STATUS_ENTER_CHILDREN() {
	STATUS_Data data;

	STATUS_Type type = STATUS_ENTER_CHILDREN;
	
	STATUS_Enum aux = (STATUS_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATUS_Enum create_STATUS_EXECUTE_STATE() {
	STATUS_Data data;

	STATUS_Type type = STATUS_EXECUTE_STATE;
	
	STATUS_Enum aux = (STATUS_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATUS_Enum create_STATUS_EXIT_CHILDREN() {
	STATUS_Data data;

	STATUS_Type type = STATUS_EXIT_CHILDREN;
	
	STATUS_Enum aux = (STATUS_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATUS_Enum create_STATUS_EXIT_STATE() {
	STATUS_Data data;

	STATUS_Type type = STATUS_EXIT_STATE;
	
	STATUS_Enum aux = (STATUS_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATUS_Enum create_STATUS_INACTIVE() {
	STATUS_Data data;

	STATUS_Type type = STATUS_INACTIVE;
	
	STATUS_Enum aux = (STATUS_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum RESULT */

typedef enum {
	RESULT_WAIT,
	RESULT_CONT,
} RESULT_Type;

typedef union {
} RESULT_Data;

typedef struct {
	RESULT_Type type;
	RESULT_Data data;
} RESULT_Enum;

RESULT_Enum create_RESULT_WAIT() {
	RESULT_Data data;

	RESULT_Type type = RESULT_WAIT;
	
	RESULT_Enum aux = (RESULT_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
RESULT_Enum create_RESULT_CONT() {
	RESULT_Data data;

	RESULT_Type type = RESULT_CONT;
	
	RESULT_Enum aux = (RESULT_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum STATES_stm_ref0 */

typedef enum {
	STATES_stm_ref0_NONE,
	STATES_stm_ref0_Wait,
	STATES_stm_ref0_Compute,
	STATES_stm_ref0_SwingUp,
	STATES_stm_ref0_Balance,
	STATES_stm_ref0_ClampHigh,
	STATES_stm_ref0_ClampLow,
	STATES_stm_ref0_InRange,
	STATES_stm_ref0_Output,
} STATES_stm_ref0_Type;

typedef union {
} STATES_stm_ref0_Data;

typedef struct {
	STATES_stm_ref0_Type type;
	STATES_stm_ref0_Data data;
} STATES_stm_ref0_Enum;

STATES_stm_ref0_Enum create_STATES_stm_ref0_NONE() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_NONE;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_Wait() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_Wait;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_Compute() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_Compute;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_SwingUp() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_SwingUp;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_Balance() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_Balance;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_ClampHigh() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_ClampHigh;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_ClampLow() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_ClampLow;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_InRange() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_InRange;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_Output() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_Output;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum TRANSITIONS_stm_ref0 */

typedef enum {
	TRANSITIONS_stm_ref0_NONE,
	TRANSITIONS_stm_ref0_stm_ref0_t_clamp_high,
	TRANSITIONS_stm_ref0_stm_ref0_t_clamp_low,
	TRANSITIONS_stm_ref0_stm_ref0_t_swing_to_clamp,
	TRANSITIONS_stm_ref0_stm_ref0_t_high_to_output,
	TRANSITIONS_stm_ref0_stm_ref0_t_output_to_wait,
	TRANSITIONS_stm_ref0_stm_ref0_t_swing,
	TRANSITIONS_stm_ref0_stm_ref0_t_range_to_output,
	TRANSITIONS_stm_ref0_stm_ref0_t_init,
	TRANSITIONS_stm_ref0_stm_ref0_t_in_range,
	TRANSITIONS_stm_ref0_stm_ref0_t_recv_sensors,
	TRANSITIONS_stm_ref0_stm_ref0_t_to_mode,
	TRANSITIONS_stm_ref0_stm_ref0_t_balance_to_clamp,
	TRANSITIONS_stm_ref0_stm_ref0_t_low_to_output,
	TRANSITIONS_stm_ref0_stm_ref0_t_balance,
} TRANSITIONS_stm_ref0_Type;

typedef union {
} TRANSITIONS_stm_ref0_Data;

typedef struct {
	TRANSITIONS_stm_ref0_Type type;
	TRANSITIONS_stm_ref0_Data data;
} TRANSITIONS_stm_ref0_Enum;

TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_NONE() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_NONE;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_clamp_high() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_clamp_high;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_clamp_low() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_clamp_low;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_to_clamp() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_swing_to_clamp;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_high_to_output() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_high_to_output;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_output_to_wait() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_output_to_wait;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_swing() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_swing;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_range_to_output() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_range_to_output;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_init() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_init;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_in_range() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_in_range;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_recv_sensors() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_recv_sensors;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_to_mode() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_to_mode;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_to_clamp() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_balance_to_clamp;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_low_to_output() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_low_to_output;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_balance() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_balance;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum M_AcrobotSwingUpLQRModule_input */

typedef enum {
	M_AcrobotSwingUpLQRModule_input_sensorUpdate,
	M_AcrobotSwingUpLQRModule_input__done_,
	M_AcrobotSwingUpLQRModule_input__terminate_,
} M_AcrobotSwingUpLQRModule_input_Type;

typedef struct {
	struct AcrobotSensorState v1;
} M_AcrobotSwingUpLQRModule_input_sensorUpdate_Data;

typedef union {
	M_AcrobotSwingUpLQRModule_input_sensorUpdate_Data sensorUpdate;
} M_AcrobotSwingUpLQRModule_input_Data;

typedef struct {
	M_AcrobotSwingUpLQRModule_input_Type type;
	M_AcrobotSwingUpLQRModule_input_Data data;
} M_AcrobotSwingUpLQRModule_input_Enum;

M_AcrobotSwingUpLQRModule_input_Enum create_M_AcrobotSwingUpLQRModule_input_sensorUpdate(struct AcrobotSensorState v1) {
	M_AcrobotSwingUpLQRModule_input_Data data;
		
	data.sensorUpdate.v1 = v1;	

	M_AcrobotSwingUpLQRModule_input_Type type = M_AcrobotSwingUpLQRModule_input_sensorUpdate;
	
	M_AcrobotSwingUpLQRModule_input_Enum aux = (M_AcrobotSwingUpLQRModule_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
M_AcrobotSwingUpLQRModule_input_Enum create_M_AcrobotSwingUpLQRModule_input__done_() {
	M_AcrobotSwingUpLQRModule_input_Data data;

	M_AcrobotSwingUpLQRModule_input_Type type = M_AcrobotSwingUpLQRModule_input__done_;
	
	M_AcrobotSwingUpLQRModule_input_Enum aux = (M_AcrobotSwingUpLQRModule_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
M_AcrobotSwingUpLQRModule_input_Enum create_M_AcrobotSwingUpLQRModule_input__terminate_() {
	M_AcrobotSwingUpLQRModule_input_Data data;

	M_AcrobotSwingUpLQRModule_input_Type type = M_AcrobotSwingUpLQRModule_input__terminate_;
	
	M_AcrobotSwingUpLQRModule_input_Enum aux = (M_AcrobotSwingUpLQRModule_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum M_AcrobotSwingUpLQRModule_output */

typedef enum {
	M_AcrobotSwingUpLQRModule_output_ApplyTorque,
	M_AcrobotSwingUpLQRModule_output__done_,
} M_AcrobotSwingUpLQRModule_output_Type;

typedef struct {
	float v1;
} M_AcrobotSwingUpLQRModule_output_ApplyTorque_Data;

typedef union {
	M_AcrobotSwingUpLQRModule_output_ApplyTorque_Data ApplyTorque;
} M_AcrobotSwingUpLQRModule_output_Data;

typedef struct {
	M_AcrobotSwingUpLQRModule_output_Type type;
	M_AcrobotSwingUpLQRModule_output_Data data;
} M_AcrobotSwingUpLQRModule_output_Enum;

M_AcrobotSwingUpLQRModule_output_Enum create_M_AcrobotSwingUpLQRModule_output_ApplyTorque(float v1) {
	M_AcrobotSwingUpLQRModule_output_Data data;
		
	data.ApplyTorque.v1 = v1;	

	M_AcrobotSwingUpLQRModule_output_Type type = M_AcrobotSwingUpLQRModule_output_ApplyTorque;
	
	M_AcrobotSwingUpLQRModule_output_Enum aux = (M_AcrobotSwingUpLQRModule_output_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
M_AcrobotSwingUpLQRModule_output_Enum create_M_AcrobotSwingUpLQRModule_output__done_() {
	M_AcrobotSwingUpLQRModule_output_Data data;

	M_AcrobotSwingUpLQRModule_output_Type type = M_AcrobotSwingUpLQRModule_output__done_;
	
	M_AcrobotSwingUpLQRModule_output_Enum aux = (M_AcrobotSwingUpLQRModule_output_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum stm_ref0_input */

typedef enum {
	stm_ref0_input_sensorUpdate,
	stm_ref0_input__done_,
	stm_ref0_input__terminate_,
} stm_ref0_input_Type;

typedef struct {
	struct AcrobotSensorState v1;
} stm_ref0_input_sensorUpdate_Data;

typedef union {
	stm_ref0_input_sensorUpdate_Data sensorUpdate;
} stm_ref0_input_Data;

typedef struct {
	stm_ref0_input_Type type;
	stm_ref0_input_Data data;
} stm_ref0_input_Enum;

stm_ref0_input_Enum create_stm_ref0_input_sensorUpdate(struct AcrobotSensorState v1) {
	stm_ref0_input_Data data;
		
	data.sensorUpdate.v1 = v1;	

	stm_ref0_input_Type type = stm_ref0_input_sensorUpdate;
	
	stm_ref0_input_Enum aux = (stm_ref0_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
stm_ref0_input_Enum create_stm_ref0_input__done_() {
	stm_ref0_input_Data data;

	stm_ref0_input_Type type = stm_ref0_input__done_;
	
	stm_ref0_input_Enum aux = (stm_ref0_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
stm_ref0_input_Enum create_stm_ref0_input__terminate_() {
	stm_ref0_input_Data data;

	stm_ref0_input_Type type = stm_ref0_input__terminate_;
	
	stm_ref0_input_Enum aux = (stm_ref0_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum C_ctrl_ref0_input */

typedef enum {
	C_ctrl_ref0_input_sensorUpdate,
	C_ctrl_ref0_input__done_,
	C_ctrl_ref0_input__terminate_,
} C_ctrl_ref0_input_Type;

typedef struct {
	struct AcrobotSensorState v1;
} C_ctrl_ref0_input_sensorUpdate_Data;

typedef union {
	C_ctrl_ref0_input_sensorUpdate_Data sensorUpdate;
} C_ctrl_ref0_input_Data;

typedef struct {
	C_ctrl_ref0_input_Type type;
	C_ctrl_ref0_input_Data data;
} C_ctrl_ref0_input_Enum;

C_ctrl_ref0_input_Enum create_C_ctrl_ref0_input_sensorUpdate(struct AcrobotSensorState v1) {
	C_ctrl_ref0_input_Data data;
		
	data.sensorUpdate.v1 = v1;	

	C_ctrl_ref0_input_Type type = C_ctrl_ref0_input_sensorUpdate;
	
	C_ctrl_ref0_input_Enum aux = (C_ctrl_ref0_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
C_ctrl_ref0_input_Enum create_C_ctrl_ref0_input__done_() {
	C_ctrl_ref0_input_Data data;

	C_ctrl_ref0_input_Type type = C_ctrl_ref0_input__done_;
	
	C_ctrl_ref0_input_Enum aux = (C_ctrl_ref0_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
C_ctrl_ref0_input_Enum create_C_ctrl_ref0_input__terminate_() {
	C_ctrl_ref0_input_Data data;

	C_ctrl_ref0_input_Type type = C_ctrl_ref0_input__terminate_;
	
	C_ctrl_ref0_input_Enum aux = (C_ctrl_ref0_input_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum stm_ref0_output */

typedef enum {
	stm_ref0_output_ApplyTorque,
	stm_ref0_output__done_,
} stm_ref0_output_Type;

typedef struct {
	float v1;
} stm_ref0_output_ApplyTorque_Data;

typedef union {
	stm_ref0_output_ApplyTorque_Data ApplyTorque;
} stm_ref0_output_Data;

typedef struct {
	stm_ref0_output_Type type;
	stm_ref0_output_Data data;
} stm_ref0_output_Enum;

stm_ref0_output_Enum create_stm_ref0_output_ApplyTorque(float v1) {
	stm_ref0_output_Data data;
		
	data.ApplyTorque.v1 = v1;	

	stm_ref0_output_Type type = stm_ref0_output_ApplyTorque;
	
	stm_ref0_output_Enum aux = (stm_ref0_output_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
stm_ref0_output_Enum create_stm_ref0_output__done_() {
	stm_ref0_output_Data data;

	stm_ref0_output_Type type = stm_ref0_output__done_;
	
	stm_ref0_output_Enum aux = (stm_ref0_output_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum C_ctrl_ref0_output */

typedef enum {
	C_ctrl_ref0_output_ApplyTorque,
	C_ctrl_ref0_output__done_,
} C_ctrl_ref0_output_Type;

typedef struct {
	float v1;
} C_ctrl_ref0_output_ApplyTorque_Data;

typedef union {
	C_ctrl_ref0_output_ApplyTorque_Data ApplyTorque;
} C_ctrl_ref0_output_Data;

typedef struct {
	C_ctrl_ref0_output_Type type;
	C_ctrl_ref0_output_Data data;
} C_ctrl_ref0_output_Enum;

C_ctrl_ref0_output_Enum create_C_ctrl_ref0_output_ApplyTorque(float v1) {
	C_ctrl_ref0_output_Data data;
		
	data.ApplyTorque.v1 = v1;	

	C_ctrl_ref0_output_Type type = C_ctrl_ref0_output_ApplyTorque;
	
	C_ctrl_ref0_output_Enum aux = (C_ctrl_ref0_output_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
C_ctrl_ref0_output_Enum create_C_ctrl_ref0_output__done_() {
	C_ctrl_ref0_output_Data data;

	C_ctrl_ref0_output_Type type = C_ctrl_ref0_output__done_;
	
	C_ctrl_ref0_output_Enum aux = (C_ctrl_ref0_output_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}

/* Representation of record AcrobotSensorState */
// MANUAL ADAPTATION: Commented out - struct defined at top of file
// struct AcrobotSensorState {
// 	float elbowAngle;
// 	float elbowVelocity;
// 	float shoulderAngle;
// 	float shoulderVelocity;
// };
/* Representation of record stm_ref0_state */
struct stm_ref0_state {
	bool done;
	STATES_stm_ref0_Enum state;
	STATES_stm_ref0_Enum target_state;
	STATUS_Enum status;
	bool en_AcrobotSwingUpLQR_Output_1_done;
	int en_AcrobotSwingUpLQR_Output_1_counter;
	bool en_AcrobotSwingUpLQR_InRange_1_done;
	int en_AcrobotSwingUpLQR_InRange_1_counter;
	bool en_AcrobotSwingUpLQR_Balance_1_done;
	int en_AcrobotSwingUpLQR_Balance_1_counter;
	bool en_AcrobotSwingUpLQR_ClampLow_1_done;
	int en_AcrobotSwingUpLQR_ClampLow_1_counter;
	bool en_AcrobotSwingUpLQR_Compute_1_done;
	int en_AcrobotSwingUpLQR_Compute_1_counter;
	bool en_AcrobotSwingUpLQR_ClampHigh_1_done;
	int en_AcrobotSwingUpLQR_ClampHigh_1_counter;
	bool en_AcrobotSwingUpLQR_SwingUp_1_done;
	int en_AcrobotSwingUpLQR_SwingUp_1_counter;
	bool tr_AcrobotSwingUpLQR_t_recv_sensors_done;
	int tr_AcrobotSwingUpLQR_t_recv_sensors_counter;
	bool tr_AcrobotSwingUpLQR_t_output_to_wait_done;
	int tr_AcrobotSwingUpLQR_t_output_to_wait_counter;
};
/* Representation of record stm_ref0_inputstate */
struct stm_ref0_inputstate {
	bool sensorUpdate;
	struct AcrobotSensorState sensorUpdate_value;
	int _clock_C;
	TRANSITIONS_stm_ref0_Enum _transition_;
};
/* Representation of record stm_ref0_memory */
struct stm_ref0_memory {
	float K1;
	float cost;
	float sin_q1;
	float l2;
	float balancing_threshold;
	float x_err3;
	float tau_raw;
	float M12;
	float E_tilde;
	float S13;
	float shoulder_velocity;
	float x_err2;
	float m2;
	float a3;
	float sin_q2;
	float S11;
	float Ic2;
	float lc1;
	float M11;
	float l1;
	float lc2;
	float S03;
	float S23;
	float q1;
	float m1;
	float K0;
	float KE;
	float S01;
	float u_e;
	float S33;
	float TAU_MAX;
	float S02;
	float S12;
	float x_err0;
	float a2;
	float E;
	float cos_q1_q2;
	float u_p;
	float K3;
	float S22;
	float elbow_angle;
	float q2;
	float M22;
	float shoulder_angle;
	float x_err1;
	float tau;
	float TWO_PI;
	float dq2;
	float K2;
	float det;
	float C1;
	float k_d;
	float S00;
	float cos_q2;
	float cos_q1;
	float sin_q1_q2;
	float k_p;
	bool near_upright;
	float PE;
	struct AcrobotSensorState su;
	float C2;
	float elbow_velocity;
	float Ic1;
	float E_desired;
	float wrap_tmp;
	float g;
	float dq1;
	float y;
	float k_e;
	float PI;
};

typedef struct {
	pthread_barrier_t can_write, can_read;
	C_ctrl_ref0_input_Enum value;
} C_ctrl_ref0_input_Enum_Channel;
typedef struct {
	pthread_barrier_t can_write, can_read;
	M_AcrobotSwingUpLQRModule_input_Enum value;
} M_AcrobotSwingUpLQRModule_input_Enum_Channel;
typedef struct {
	pthread_barrier_t can_write, can_read;
	C_ctrl_ref0_output_Enum value;
} C_ctrl_ref0_output_Enum_Channel;
typedef struct {
	pthread_barrier_t can_write, can_read;
	stm_ref0_input_Enum value;
} stm_ref0_input_Enum_Channel;
typedef struct {
	pthread_barrier_t can_write, can_read;
	M_AcrobotSwingUpLQRModule_output_Enum value;
} M_AcrobotSwingUpLQRModule_output_Enum_Channel;
typedef struct {
	pthread_barrier_t can_write, can_read;
	stm_ref0_output_Enum value;
} stm_ref0_output_Enum_Channel;

typedef struct {
	stm_ref0_input_Enum_Channel* start_stm_ref0;
	stm_ref0_output_Enum_Channel* end_stm_ref0;
} stm_stm_ref0_Channels;

/* Declaration of function signatures */
	// MANUAL ADAPTATION: Commented out - conflicts with math.h
	// float sin(float x);
	// float cos(float x);
	// float floor(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum AcrobotSwingUpLQR_j_clamp(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Compute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampLow_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum AcrobotSwingUpLQR_j_mode(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Output_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_InRange_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUp_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_output_to_wait(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampHigh_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Balance_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_recv_sensors(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

void *stm_stm_ref0(void *arg) {
	stm_stm_ref0_Channels* channels = (stm_stm_ref0_Channels*) arg;
	stm_ref0_input_Enum_Channel* start_stm_ref0 = channels->start_stm_ref0;
	stm_ref0_output_Enum_Channel* end_stm_ref0 = channels->end_stm_ref0;
{
	// state machine variable declarations;
	struct stm_ref0_inputstate inputstate = (struct stm_ref0_inputstate) {
	                                        	.sensorUpdate = false,
	                                        	.sensorUpdate_value = (struct AcrobotSensorState) {
	                                        		.elbowAngle = 0.0,
	                                        		.elbowVelocity = 0.0,
	                                        		.shoulderAngle = 0.0,
	                                        		.shoulderVelocity = 0.0
	                                        	},
	                                        	._clock_C = 0,
	                                        	._transition_ = create_TRANSITIONS_stm_ref0_NONE()
	                                        };
	struct stm_ref0_state state = (struct stm_ref0_state) {
	                              	.done = false,
	                              	.state = create_STATES_stm_ref0_NONE(),
	                              	.target_state = create_STATES_stm_ref0_NONE(),
	                              	.status = create_STATUS_ENTER_STATE(),
	                              	.en_AcrobotSwingUpLQR_Output_1_done = false,
	                              	.en_AcrobotSwingUpLQR_Output_1_counter = 0,
	                              	.en_AcrobotSwingUpLQR_InRange_1_done = false,
	                              	.en_AcrobotSwingUpLQR_InRange_1_counter = 0,
	                              	.en_AcrobotSwingUpLQR_Balance_1_done = false,
	                              	.en_AcrobotSwingUpLQR_Balance_1_counter = 0,
	                              	.en_AcrobotSwingUpLQR_ClampLow_1_done = false,
	                              	.en_AcrobotSwingUpLQR_ClampLow_1_counter = 0,
	                              	.en_AcrobotSwingUpLQR_Compute_1_done = false,
	                              	.en_AcrobotSwingUpLQR_Compute_1_counter = 0,
	                              	.en_AcrobotSwingUpLQR_ClampHigh_1_done = false,
	                              	.en_AcrobotSwingUpLQR_ClampHigh_1_counter = 0,
	                              	.en_AcrobotSwingUpLQR_SwingUp_1_done = false,
	                              	.en_AcrobotSwingUpLQR_SwingUp_1_counter = 0,
	                              	.tr_AcrobotSwingUpLQR_t_recv_sensors_done = false,
	                              	.tr_AcrobotSwingUpLQR_t_recv_sensors_counter = 0,
	                              	.tr_AcrobotSwingUpLQR_t_output_to_wait_done = false,
	                              	.tr_AcrobotSwingUpLQR_t_output_to_wait_counter = 0
	                              };
	struct stm_ref0_memory memorystate = (struct stm_ref0_memory) {
	                                     	.K1 = -112.29,
	                                     	.cost = 0.0,
	                                     	.sin_q1 = 0.0,
	                                     	.l2 = 2.0,
	                                     	.balancing_threshold = 1000.0,
	                                     	.x_err3 = 0.0,
	                                     	.tau_raw = 0.0,
	                                     	.M12 = 0.0,
	                                     	.E_tilde = 0.0,
	                                     	.S13 = 1608.5416,
	                                     	.shoulder_velocity = 0.0,
	                                     	.x_err2 = 0.0,
	                                     	.m2 = 1.0,
	                                     	.a3 = 0.0,
	                                     	.sin_q2 = 0.0,
	                                     	.S11 = 3374.4365,
	                                     	.Ic2 = 0.333,
	                                     	.lc1 = 0.5,
	                                     	.M11 = 0.0,
	                                     	.l1 = 1.0,
	                                     	.lc2 = 1.0,
	                                     	.S03 = 3571.581,
	                                     	.S23 = 1556.5061,
	                                     	.q1 = 0.0,
	                                     	.m1 = 1.0,
	                                     	.K0 = -278.44,
	                                     	.KE = 0.0,
	                                     	.S01 = 7470.1875,
	                                     	.u_e = 0.0,
	                                     	.S33 = 768.33307,
	                                     	.TAU_MAX = 20.0,
	                                     	.S02 = 7240.1235,
	                                     	.S12 = 3256.4028,
	                                     	.x_err0 = 0.0,
	                                     	.a2 = 0.0,
	                                     	.E = 0.0,
	                                     	.cos_q1_q2 = 0.0,
	                                     	.u_p = 0.0,
	                                     	.K3 = -56.83,
	                                     	.S22 = 3154.7305,
	                                     	.elbow_angle = 0.0,
	                                     	.q2 = 0.0,
	                                     	.M22 = 0.0,
	                                     	.shoulder_angle = 0.0,
	                                     	.x_err1 = 0.0,
	                                     	.tau = 0.0,
	                                     	.TWO_PI = 6.2831855,
	                                     	.dq2 = 0.0,
	                                     	.K2 = -119.72,
	                                     	.det = 0.0,
	                                     	.C1 = 0.0,
	                                     	.k_d = 5.0,
	                                     	.S00 = 16620.607,
	                                     	.cos_q2 = 0.0,
	                                     	.cos_q1 = 0.0,
	                                     	.sin_q1_q2 = 0.0,
	                                     	.k_p = 50.0,
	                                     	.near_upright = false,
	                                     	.PE = 0.0,
	                                     	.su = (struct AcrobotSensorState) {
	                                     		.elbowAngle = 0.0,
	                                     		.elbowVelocity = 0.0,
	                                     		.shoulderAngle = 0.0,
	                                     		.shoulderVelocity = 0.0
	                                     	},
	                                     	.C2 = 0.0,
	                                     	.elbow_velocity = 0.0,
	                                     	.Ic1 = 0.083,
	                                     	.E_desired = 0.0,
	                                     	.wrap_tmp = 0.0,
	                                     	.g = 9.81,
	                                     	.dq1 = 0.0,
	                                     	.y = 0.0,
	                                     	.k_e = 5.0,
	                                     	.PI = 3.1415927
	                                     };
	// state machine loop;
	while (!(state).done) {
		{
			{
				char _s0[256];
				sprintf(_s0, "%s", "- Waiting for input on channel start_stm_ref0");
				fprintf(log_file, "DEBUG: %s\n", _s0);
			}
			bool inputDone = false;
			while (!inputDone) {
				stm_ref0_input_Enum _input_;
				{	
					pthread_barrier_wait(&start_stm_ref0->can_write);
					pthread_barrier_wait(&start_stm_ref0->can_read);
					_input_ = start_stm_ref0->value;	
				}
				{
					char _s0[256];
					sprintf(_s0, "%s", "- Read input on channel start_stm_ref0");
					fprintf(log_file, "DEBUG: %s\n", _s0);
				}
				if (_input_.type == stm_ref0_input_sensorUpdate) {
					struct AcrobotSensorState _aux_ = _input_.data.sensorUpdate.v1;	
					(inputstate).sensorUpdate = true;
					(inputstate).sensorUpdate_value = _aux_;
				}
				else if (_input_.type == stm_ref0_input__done_) {
				     	inputDone = true;
				     }
				else if (_input_.type == stm_ref0_input__terminate_) {
				     	inputDone = true;
				     	(state).done = true;
				     }
			}
		}
		RESULT_Enum ret = create_RESULT_CONT();
		while (	ret.type == create_RESULT_CONT().type
		        ) {
			char* temp_;
			temp_ = print_stm_ref0_state(&state);
			{
				char _s0[256];
				sprintf(_s0, "%s", temp_);
				fprintf(log_file, "DEBUG: %s\n", _s0);
			}
			free(temp_);
			ret = stm_stm_ref0_step(&state, &inputstate, &memorystate, end_stm_ref0);
		}
		{
			pthread_barrier_wait(&end_stm_ref0->can_write);
			end_stm_ref0->value = create_stm_ref0_output__done_();
			pthread_barrier_wait(&end_stm_ref0->can_read);
		}
		// update clocks;
		(inputstate)._clock_C = ((inputstate)._clock_C + 1);
		// reset input events;
		(inputstate).sensorUpdate = false;
		{
			char _s0[256];
			sprintf(_s0, "%s", "		Sent output _done_ on channel end_stm_ref0");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		
	}
}
}
typedef struct {
	M_AcrobotSwingUpLQRModule_input_Enum_Channel* start_AcrobotSwingUpLQRModule;
	C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0;
	M_AcrobotSwingUpLQRModule_output_Enum_Channel* end_AcrobotSwingUpLQRModule;
	C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0;
} mod_AcrobotSwingUpLQRModule_thread_Channels;

/* Declaration of function signatures */
	// MANUAL ADAPTATION: Commented out - conflicts with math.h
	// float sin(float x);
	// float cos(float x);
	// float floor(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum AcrobotSwingUpLQR_j_clamp(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Compute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampLow_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum AcrobotSwingUpLQR_j_mode(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Output_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_InRange_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUp_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_output_to_wait(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampHigh_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Balance_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_recv_sensors(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

void *mod_AcrobotSwingUpLQRModule_thread(void *arg) {
	mod_AcrobotSwingUpLQRModule_thread_Channels* channels = (mod_AcrobotSwingUpLQRModule_thread_Channels*) arg;
	M_AcrobotSwingUpLQRModule_input_Enum_Channel* start_AcrobotSwingUpLQRModule = channels->start_AcrobotSwingUpLQRModule;
	C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0 = channels->end_ctrl_ref0;
	M_AcrobotSwingUpLQRModule_output_Enum_Channel* end_AcrobotSwingUpLQRModule = channels->end_AcrobotSwingUpLQRModule;
	C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0 = channels->start_ctrl_ref0;
{
	bool terminate__ = false;
	while (!terminate__) {
		{
			bool inputDone = false;
			while (!inputDone) {
				{
					char _s0[256];
					sprintf(_s0, "%s", "- Waiting for input on channel start_AcrobotSwingUpLQRModule");
					fprintf(log_file, "DEBUG: %s\n", _s0);
				}
				M_AcrobotSwingUpLQRModule_input_Enum _input_;
				{	
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
					_input_ = start_AcrobotSwingUpLQRModule->value;	
				}
				{
					char _s0[256];
					sprintf(_s0, "%s", "- Read input on channel start_AcrobotSwingUpLQRModule");
					fprintf(log_file, "DEBUG: %s\n", _s0);
				}
				if (_input_.type == M_AcrobotSwingUpLQRModule_input_sensorUpdate) {
					struct AcrobotSensorState _aux1_ = _input_.data.sensorUpdate.v1;	
					{
						pthread_barrier_wait(&start_ctrl_ref0->can_write);
						start_ctrl_ref0->value = create_C_ctrl_ref0_input_sensorUpdate(_aux1_);
						pthread_barrier_wait(&start_ctrl_ref0->can_read);
					}
				}
				else if (_input_.type == M_AcrobotSwingUpLQRModule_input__done_) {
				     	{
				     		pthread_barrier_wait(&start_ctrl_ref0->can_write);
				     		start_ctrl_ref0->value = create_C_ctrl_ref0_input__done_();
				     		pthread_barrier_wait(&start_ctrl_ref0->can_read);
				     	}
				     	inputDone = true;
				     }
				else if (_input_.type == M_AcrobotSwingUpLQRModule_input__terminate_) {
				     	{
				     		pthread_barrier_wait(&start_ctrl_ref0->can_write);
				     		start_ctrl_ref0->value = create_C_ctrl_ref0_input__terminate_();
				     		pthread_barrier_wait(&start_ctrl_ref0->can_read);
				     	}
				     	terminate__ = true;
				     	inputDone = true;
				     }
			}
			
		}
		{
			char _s0[256];
			sprintf(_s0, "%s", "Finished reading inputs of module AcrobotSwingUpLQRModule");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (terminate__) {
			break;
		}
		mod_AcrobotSwingUpLQRModule_step(start_ctrl_ref0, end_ctrl_ref0);
		{
			bool outputDone = false;
			while (!outputDone) {
				C_ctrl_ref0_output_Enum _output_;
				{	
					pthread_barrier_wait(&end_ctrl_ref0->can_write);
					pthread_barrier_wait(&end_ctrl_ref0->can_read);
					_output_ = end_ctrl_ref0->value;	
				}
				if (_output_.type == C_ctrl_ref0_output_ApplyTorque) {
					float _aux1_ = _output_.data.ApplyTorque.v1;	
					{
						pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_write);
						end_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_output_ApplyTorque(_aux1_);
						pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_read);
					}
				}
				else if (_output_.type == C_ctrl_ref0_output__done_) {
				     	outputDone = true;
				     }
			}
			
		}
		{
			pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_write);
			end_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_output__done_();
			pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_read);
		}
	}
}
}
typedef struct {
	M_AcrobotSwingUpLQRModule_output_Enum_Channel* end_AcrobotSwingUpLQRModule;
	M_AcrobotSwingUpLQRModule_input_Enum_Channel* start_AcrobotSwingUpLQRModule;
} control_Channels;

/* Declaration of function signatures */
	// MANUAL ADAPTATION: Commented out - conflicts with math.h
	// float sin(float x);
	// float cos(float x);
	// float floor(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum AcrobotSwingUpLQR_j_clamp(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Compute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampLow_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum AcrobotSwingUpLQR_j_mode(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Output_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_InRange_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUp_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_output_to_wait(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampHigh_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Balance_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_recv_sensors(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

// MANUAL ADAPTATION: Replaced stdin/stdout control loop with registerRead-based version
void *control(void *arg) {
	control_Channels* channels = (control_Channels*) arg;
	M_AcrobotSwingUpLQRModule_output_Enum_Channel* end_AcrobotSwingUpLQRModule = channels->end_AcrobotSwingUpLQRModule;
	M_AcrobotSwingUpLQRModule_input_Enum_Channel* start_AcrobotSwingUpLQRModule = channels->start_AcrobotSwingUpLQRModule;

	bool terminate__ = false;
	while (!terminate__) {
		// Read input from orchestrator
		bool inputdone = false;
		while (!inputdone) {
			int input_type;
			AcrobotSensorState sensor_data;  // Uses typedef from dmodel_interface.h (doubles)

			bool read_ok = registerRead(&input_type, &sensor_data, sizeof(sensor_data));
			if (!read_ok) {
				// registerRead() reports termination via return value; still propagate an explicit
				// terminate event through the generated channels so that all threads can exit.
				input_type = INPUT_TERMINATE;
			}

			if (input_type == INPUT_SENSOR_UPDATE) {
				// Convert doubles from orchestrator to floats for generated code
				struct AcrobotSensorState _value_ = {
					.shoulderAngle = (float)sensor_data.shoulderAngle,
					.shoulderVelocity = (float)sensor_data.shoulderVelocity,
					.elbowAngle = (float)sensor_data.elbowAngle,
					.elbowVelocity = (float)sensor_data.elbowVelocity
				};

				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
				start_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_input_sensorUpdate(_value_);
				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
			}
			else if (input_type == INPUT_DONE) {
				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
				start_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_input__done_();
				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
				inputdone = true;
			}
			else if (input_type == INPUT_TERMINATE) {
				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
				start_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_input__terminate_();
				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
				terminate__ = true;
				inputdone = true;
			}
		}

		if (terminate__) break;

		// Read outputs from d-model and send to orchestrator
		bool outputdone = false;
		while (!outputdone) {
			M_AcrobotSwingUpLQRModule_output_Enum _output_;
			pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_write);
			pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_read);
			_output_ = end_AcrobotSwingUpLQRModule->value;

			if (_output_.type == M_AcrobotSwingUpLQRModule_output_ApplyTorque) {
				float tau = _output_.data.ApplyTorque.v1;
				registerWrite(&(OperationData){OUTPUT_CONTROL_IN, 1, {(double)tau}, 0.0});
			}
			else if (_output_.type == M_AcrobotSwingUpLQRModule_output__done_) {
				registerWrite(&(OperationData){OUTPUT_DONE, 0, {0.0}, 0.0});
				tock(INPUT_DONE);
				outputdone = true;
			}
		}
	}
	return NULL;
}
typedef struct {
	C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0;
	stm_ref0_output_Enum_Channel* end_stm_ref0;
	C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0;
	stm_ref0_input_Enum_Channel* start_stm_ref0;
} ctrl_ctrl_ref0_thread_Channels;

/* Declaration of function signatures */
	// MANUAL ADAPTATION: Commented out - conflicts with math.h
	// float sin(float x);
	// float cos(float x);
	// float floor(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum AcrobotSwingUpLQR_j_clamp(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Compute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampLow_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum AcrobotSwingUpLQR_j_mode(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Output_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_InRange_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUp_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_output_to_wait(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_ClampHigh_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_Balance_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_recv_sensors(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

void *ctrl_ctrl_ref0_thread(void *arg) {
	ctrl_ctrl_ref0_thread_Channels* channels = (ctrl_ctrl_ref0_thread_Channels*) arg;
	C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0 = channels->start_ctrl_ref0;
	stm_ref0_output_Enum_Channel* end_stm_ref0 = channels->end_stm_ref0;
	C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0 = channels->end_ctrl_ref0;
	stm_ref0_input_Enum_Channel* start_stm_ref0 = channels->start_stm_ref0;
{
	bool terminate__ = false;
	struct {
	    stm_ref0_input_Enum items[MAXQUEUE];
	    int start;
	    int end;
	} stm_stm_ref0_queue;
	stm_stm_ref0_queue.start = -1;
	stm_stm_ref0_queue.end = -1;
	
	stm_ref0_input_Enum stm_stm_ref0_queue_Dequeue() {
		if (stm_stm_ref0_queue.start == -1) {
			printf("ERROR: trying to dequeue value from an empty queue.\n");
			exit(-1);
		} else {
			stm_ref0_input_Enum value = stm_stm_ref0_queue.items[stm_stm_ref0_queue.start];
		    if (stm_stm_ref0_queue.start == stm_stm_ref0_queue.end) {
		        stm_stm_ref0_queue.start = stm_stm_ref0_queue.end = -1;
		    } else {
		        stm_stm_ref0_queue.start = (stm_stm_ref0_queue.start + 1)%MAXQUEUE;
		    }
		    return value;
		}
	}
	
	void stm_stm_ref0_queue_Enqueue(stm_ref0_input_Enum value) {
		if (stm_stm_ref0_queue.start == (stm_stm_ref0_queue.end +1)%MAXQUEUE) {
	        printf("ERROR: trying to enqueue a value on a full queue.\n");
	        return;
	    }
	
	    if (stm_stm_ref0_queue.start == -1) {
	        stm_stm_ref0_queue.start = 0;
	    }
	    stm_stm_ref0_queue.end = (stm_stm_ref0_queue.end + 1)%MAXQUEUE;
	    stm_stm_ref0_queue.items[stm_stm_ref0_queue.end] = value;
	}
	
	bool stm_stm_ref0_queue_isEmpty() {
		return stm_stm_ref0_queue.start == -1;
	}
	
	void stm_stm_ref0_queue_Clear() {
		stm_stm_ref0_queue.start = -1;
		stm_stm_ref0_queue.end = -1;
	}
	while (!terminate__) {
		while (!stm_stm_ref0_queue_isEmpty()) {
			stm_ref0_input_Enum ev = stm_stm_ref0_queue_Dequeue();
			{
				pthread_barrier_wait(&start_stm_ref0->can_write);
				start_stm_ref0->value = ev;
				pthread_barrier_wait(&start_stm_ref0->can_read);
			}
		}
		{
			bool inputDone = false;
			while (!inputDone) {
				{
					char _s0[256];
					sprintf(_s0, "%s", "- Waiting for input on channel start_ctrl_ref0");
					fprintf(log_file, "DEBUG: %s\n", _s0);
				}
				C_ctrl_ref0_input_Enum _input_;
				{	
					pthread_barrier_wait(&start_ctrl_ref0->can_write);
					pthread_barrier_wait(&start_ctrl_ref0->can_read);
					_input_ = start_ctrl_ref0->value;	
				}
				{
					char _s0[256];
					sprintf(_s0, "%s", "- Read input on channel start_ctrl_ref0");
					fprintf(log_file, "DEBUG: %s\n", _s0);
				}
				if (_input_.type == C_ctrl_ref0_input_sensorUpdate) {
					struct AcrobotSensorState _aux1_ = _input_.data.sensorUpdate.v1;	
					{
						pthread_barrier_wait(&start_stm_ref0->can_write);
						start_stm_ref0->value = create_stm_ref0_input_sensorUpdate(_aux1_);
						pthread_barrier_wait(&start_stm_ref0->can_read);
					}
				}
				else if (_input_.type == C_ctrl_ref0_input__done_) {
				     	{
				     		pthread_barrier_wait(&start_stm_ref0->can_write);
				     		start_stm_ref0->value = create_stm_ref0_input__done_();
				     		pthread_barrier_wait(&start_stm_ref0->can_read);
				     	}
				     	inputDone = true;
				     }
				else if (_input_.type == C_ctrl_ref0_input__terminate_) {
				     	{
				     		pthread_barrier_wait(&start_stm_ref0->can_write);
				     		start_stm_ref0->value = create_stm_ref0_input__terminate_();
				     		pthread_barrier_wait(&start_stm_ref0->can_read);
				     	}
				     	terminate__ = true;
				     	inputDone = true;
				     }
			}
			
		}
		{
			char _s0[256];
			sprintf(_s0, "%s", "	Finished reading inputs of controller ctrl_ref0");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (terminate__) {
			break;
		}
		ctrl_ctrl_ref0_step(start_stm_ref0, end_stm_ref0);
		{
			bool outputDone = false;
			while (!outputDone) {
				stm_ref0_output_Enum _output_;
				{	
					pthread_barrier_wait(&end_stm_ref0->can_write);
					pthread_barrier_wait(&end_stm_ref0->can_read);
					_output_ = end_stm_ref0->value;	
				}
				if (_output_.type == stm_ref0_output_ApplyTorque) {
					float _aux1_ = _output_.data.ApplyTorque.v1;	
					{
						pthread_barrier_wait(&end_ctrl_ref0->can_write);
						end_ctrl_ref0->value = create_C_ctrl_ref0_output_ApplyTorque(_aux1_);
						pthread_barrier_wait(&end_ctrl_ref0->can_read);
					}
				}
				else if (_output_.type == stm_ref0_output__done_) {
				     	outputDone = true;
				     }
			}
			
		}
		{
			pthread_barrier_wait(&end_ctrl_ref0->can_write);
			end_ctrl_ref0->value = create_C_ctrl_ref0_output__done_();
			pthread_barrier_wait(&end_ctrl_ref0->can_read);
		}
	}
}
}

// MANUAL ADAPTATION: Renamed from main() to allow orchestrator to call it
int acrobot_generated_main(int argc, char* argv[]) {
	//let _ = WriteLogger::init(
	//	LevelFilter::Trace, Config::default(), File::create("test.log").unwrap());
	log_file = fopen("test.log", "w");
	
	//let _args: Vec<String> = std::env::args().collect();
    if (argc  <= 0) {
        fprintf(stderr, "error: Not enough arguments.");
        exit(1);
    }

	// Module channel declarations;
	M_AcrobotSwingUpLQRModule_input_Enum_Channel* start_AcrobotSwingUpLQRModule = (M_AcrobotSwingUpLQRModule_input_Enum_Channel*)malloc(sizeof(M_AcrobotSwingUpLQRModule_input_Enum_Channel));
	pthread_barrier_init(&start_AcrobotSwingUpLQRModule->can_read, NULL, 2);
	pthread_barrier_init(&start_AcrobotSwingUpLQRModule->can_write, NULL, 2);
	M_AcrobotSwingUpLQRModule_output_Enum_Channel* end_AcrobotSwingUpLQRModule = (M_AcrobotSwingUpLQRModule_output_Enum_Channel*)malloc(sizeof(M_AcrobotSwingUpLQRModule_output_Enum_Channel));
	pthread_barrier_init(&end_AcrobotSwingUpLQRModule->can_read, NULL, 2);
	pthread_barrier_init(&end_AcrobotSwingUpLQRModule->can_write, NULL, 2);
	C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0 = (C_ctrl_ref0_input_Enum_Channel*)malloc(sizeof(C_ctrl_ref0_input_Enum_Channel));
	pthread_barrier_init(&start_ctrl_ref0->can_read, NULL, 2);
	pthread_barrier_init(&start_ctrl_ref0->can_write, NULL, 2);
	C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0 = (C_ctrl_ref0_output_Enum_Channel*)malloc(sizeof(C_ctrl_ref0_output_Enum_Channel));
	pthread_barrier_init(&end_ctrl_ref0->can_read, NULL, 2);
	pthread_barrier_init(&end_ctrl_ref0->can_write, NULL, 2);
	stm_ref0_input_Enum_Channel* start_stm_ref0 = (stm_ref0_input_Enum_Channel*)malloc(sizeof(stm_ref0_input_Enum_Channel));
	pthread_barrier_init(&start_stm_ref0->can_read, NULL, 2);
	pthread_barrier_init(&start_stm_ref0->can_write, NULL, 2);
	stm_ref0_output_Enum_Channel* end_stm_ref0 = (stm_ref0_output_Enum_Channel*)malloc(sizeof(stm_ref0_output_Enum_Channel));
	pthread_barrier_init(&end_stm_ref0->can_read, NULL, 2);
	pthread_barrier_init(&end_stm_ref0->can_write, NULL, 2);
	// Instantiate threads;
	int status;
	pthread_t control_id;
	control_Channels* control_channels = (control_Channels*)malloc(sizeof(control_Channels));
	
	control_channels->end_AcrobotSwingUpLQRModule = end_AcrobotSwingUpLQRModule;
	control_channels->start_AcrobotSwingUpLQRModule = start_AcrobotSwingUpLQRModule;
	
	status = pthread_create(&control_id, NULL, control, control_channels);
	if (status != 0)
			err_abort(status, "Create control thread");
	pthread_t mod_AcrobotSwingUpLQRModule_thread_id;
	mod_AcrobotSwingUpLQRModule_thread_Channels* mod_AcrobotSwingUpLQRModule_thread_channels = (mod_AcrobotSwingUpLQRModule_thread_Channels*)malloc(sizeof(mod_AcrobotSwingUpLQRModule_thread_Channels));
	
	mod_AcrobotSwingUpLQRModule_thread_channels->start_AcrobotSwingUpLQRModule = start_AcrobotSwingUpLQRModule;
	mod_AcrobotSwingUpLQRModule_thread_channels->end_ctrl_ref0 = end_ctrl_ref0;
	mod_AcrobotSwingUpLQRModule_thread_channels->end_AcrobotSwingUpLQRModule = end_AcrobotSwingUpLQRModule;
	mod_AcrobotSwingUpLQRModule_thread_channels->start_ctrl_ref0 = start_ctrl_ref0;
	
	status = pthread_create(&mod_AcrobotSwingUpLQRModule_thread_id, NULL, mod_AcrobotSwingUpLQRModule_thread, mod_AcrobotSwingUpLQRModule_thread_channels);
	if (status != 0)
			err_abort(status, "Create mod_AcrobotSwingUpLQRModule_thread thread");
	pthread_t stm_stm_ref0_id;
	stm_stm_ref0_Channels* stm_stm_ref0_channels = (stm_stm_ref0_Channels*)malloc(sizeof(stm_stm_ref0_Channels));
	
	stm_stm_ref0_channels->start_stm_ref0 = start_stm_ref0;
	stm_stm_ref0_channels->end_stm_ref0 = end_stm_ref0;
	
	status = pthread_create(&stm_stm_ref0_id, NULL, stm_stm_ref0, stm_stm_ref0_channels);
	if (status != 0)
			err_abort(status, "Create stm_stm_ref0 thread");
	pthread_t ctrl_ctrl_ref0_thread_id;
	ctrl_ctrl_ref0_thread_Channels* ctrl_ctrl_ref0_thread_channels = (ctrl_ctrl_ref0_thread_Channels*)malloc(sizeof(ctrl_ctrl_ref0_thread_Channels));
	
	ctrl_ctrl_ref0_thread_channels->start_ctrl_ref0 = start_ctrl_ref0;
	ctrl_ctrl_ref0_thread_channels->end_stm_ref0 = end_stm_ref0;
	ctrl_ctrl_ref0_thread_channels->end_ctrl_ref0 = end_ctrl_ref0;
	ctrl_ctrl_ref0_thread_channels->start_stm_ref0 = start_stm_ref0;
	
	status = pthread_create(&ctrl_ctrl_ref0_thread_id, NULL, ctrl_ctrl_ref0_thread, ctrl_ctrl_ref0_thread_channels);
	if (status != 0)
			err_abort(status, "Create ctrl_ctrl_ref0_thread thread");
		
	status = pthread_join(control_id, NULL);
	if (status != 0)
			err_abort(status, "Join control thread");		
	status = pthread_join(mod_AcrobotSwingUpLQRModule_thread_id, NULL);
	if (status != 0)
			err_abort(status, "Join mod_AcrobotSwingUpLQRModule_thread thread");		
	status = pthread_join(stm_stm_ref0_id, NULL);
	if (status != 0)
			err_abort(status, "Join stm_stm_ref0 thread");		
	status = pthread_join(ctrl_ctrl_ref0_thread_id, NULL);
	if (status != 0)
			err_abort(status, "Join ctrl_ctrl_ref0_thread thread");		
	// Free channels;
	free(start_AcrobotSwingUpLQRModule);
	free(end_AcrobotSwingUpLQRModule);
	free(start_ctrl_ref0);
	free(end_ctrl_ref0);
	free(start_stm_ref0);
	free(end_stm_ref0);
	free(control_channels);
	free(mod_AcrobotSwingUpLQRModule_thread_channels);
	free(stm_stm_ref0_channels);
	free(ctrl_ctrl_ref0_thread_channels);
	
	fclose(log_file);
	return 0;
}

	// MANUAL ADAPTATION: Commented out - using math.h implementations
	// float sin(float x) {
	// 	// TODO: Complete definition
	//
	// }
	// float cos(float x) {
	// 	// TODO: Complete definition
	//
	// }
	// float floor(float x) {
	// 	// TODO: Complete definition
	//
	// }
	char* print_STATUS(STATUS_Enum* value) {
		if (value->type == STATUS_ENTER_STATE) {
			return "ENTER_STATE";
		}
		else if (value->type == STATUS_ENTER_CHILDREN) {
		     	return "ENTER_CHILDREN";
		     }
		else if (value->type == STATUS_EXECUTE_STATE) {
		     	return "EXECUTE_STATE";
		     }
		else if (value->type == STATUS_EXIT_CHILDREN) {
		     	return "EXIT_CHILDREN";
		     }
		else if (value->type == STATUS_EXIT_STATE) {
		     	return "EXIT_STATE";
		     }
		else if (value->type == STATUS_INACTIVE) {
		     	return "INACTIVE";
		     }
	}
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Started step of module AcrobotSwingUpLQRModule");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		{
			char _s0[256];
			sprintf(_s0, "%s", "Finished step of module AcrobotSwingUpLQRModule");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
	}
	RESULT_Enum AcrobotSwingUpLQR_j_clamp(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output) {
		if ((memorystate)->tau_raw > (memorystate)->TAU_MAX) {
			(*state).state = create_STATES_stm_ref0_ClampHigh();
			(*state).status = create_STATUS_ENTER_STATE();
			return create_RESULT_CONT();
		} else if ((memorystate)->tau_raw < -(memorystate)->TAU_MAX) {
			(*state).state = create_STATES_stm_ref0_ClampLow();
			(*state).status = create_STATUS_ENTER_STATE();
			return create_RESULT_CONT();
		} else if ((memorystate)->tau_raw >= -(memorystate)->TAU_MAX && (memorystate)->tau_raw <= (memorystate)->TAU_MAX) {
			(*state).state = create_STATES_stm_ref0_InRange();
			(*state).status = create_STATUS_ENTER_STATE();
			return create_RESULT_CONT();
		} else {
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum en_AcrobotSwingUpLQR_Compute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_Compute.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 0 ) {
			(*memory).q1 = (memory)->shoulder_angle;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 1;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 1 ) {
			(*memory).q2 = (memory)->elbow_angle;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 2;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 2 ) {
			(*memory).dq1 = (memory)->shoulder_velocity;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 3;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 3 ) {
			(*memory).dq2 = (memory)->elbow_velocity;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 4;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 4 ) {
			(*memory).wrap_tmp = ((memory)->q1 / (memory)->TWO_PI);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 5;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 5 ) {
			(*memory).wrap_tmp = ((memory)->wrap_tmp - floor((memory)->wrap_tmp));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 6;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 6 ) {
			(*memory).q1 = ((memory)->wrap_tmp * (memory)->TWO_PI);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 7;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 7 ) {
			(*memory).wrap_tmp = ((((memory)->q2 + (memory)->PI)) / (memory)->TWO_PI);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 8;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 8 ) {
			(*memory).wrap_tmp = ((memory)->wrap_tmp - floor((memory)->wrap_tmp));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 9;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 9 ) {
			(*memory).q2 = (((memory)->wrap_tmp * (memory)->TWO_PI) - (memory)->PI);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 10;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 10 ) {
			(*memory).cos_q2 = cos((memory)->q2);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 11;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 11 ) {
			(*memory).sin_q2 = sin((memory)->q2);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 12;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 12 ) {
			(*memory).cos_q1 = cos((memory)->q1);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 13;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 13 ) {
			(*memory).sin_q1 = sin((memory)->q1);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 14;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 14 ) {
			(*memory).cos_q1_q2 = cos(((memory)->q1 + (memory)->q2));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 15;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 15 ) {
			(*memory).sin_q1_q2 = sin(((memory)->q1 + (memory)->q2));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 16;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 16 ) {
			(*memory).M11 = ((((memory)->Ic1 + (memory)->Ic2) + (((memory)->m1 * (memory)->lc1) * (memory)->lc1)) + ((memory)->m2 * (((((memory)->l1 * (memory)->l1) + ((memory)->lc2 * (memory)->lc2)) + (((2.0 * (memory)->l1) * (memory)->lc2) * (memory)->cos_q2)))));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 17;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 17 ) {
			(*memory).M12 = ((memory)->Ic2 + ((memory)->m2 * ((((memory)->lc2 * (memory)->lc2) + (((memory)->l1 * (memory)->lc2) * (memory)->cos_q2)))));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 18;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 18 ) {
			(*memory).M22 = ((memory)->Ic2 + (((memory)->m2 * (memory)->lc2) * (memory)->lc2));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 19;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 19 ) {
			(*memory).det = (((memory)->M11 * (memory)->M22) - ((memory)->M12 * (memory)->M12));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 20;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 20 ) {
			(*memory).x_err0 = ((memory)->q1 - (memory)->PI);
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 21;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 21 ) {
			(*memory).x_err1 = (memory)->q2;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 22;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 22 ) {
			(*memory).x_err2 = (memory)->dq1;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 23;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 23 ) {
			(*memory).x_err3 = (memory)->dq2;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 24;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 24 ) {
			(*memory).cost = ((((((((((((memory)->S00 * (memory)->x_err0) * (memory)->x_err0) + (((2.0 * (memory)->S01) * (memory)->x_err0) * (memory)->x_err1)) + (((2.0 * (memory)->S02) * (memory)->x_err0) * (memory)->x_err2)) + (((2.0 * (memory)->S03) * (memory)->x_err0) * (memory)->x_err3)) + (((memory)->S11 * (memory)->x_err1) * (memory)->x_err1)) + (((2.0 * (memory)->S12) * (memory)->x_err1) * (memory)->x_err2)) + (((2.0 * (memory)->S13) * (memory)->x_err1) * (memory)->x_err3)) + (((memory)->S22 * (memory)->x_err2) * (memory)->x_err2)) + (((2.0 * (memory)->S23) * (memory)->x_err2) * (memory)->x_err3)) + (((memory)->S33 * (memory)->x_err3) * (memory)->x_err3));
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 25;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_Compute_1_counter == 25 ) {
			(*memory).near_upright = (memory)->cost < (memory)->balancing_threshold;
			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 26;
			return create_RESULT_CONT();
		} else {
			(state)->en_AcrobotSwingUpLQR_Compute_1_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum en_AcrobotSwingUpLQR_ClampLow_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_ClampLow.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_ClampLow_1_counter == 0 ) {
			(*memory).tau = -(memory)->TAU_MAX;
			(*state).en_AcrobotSwingUpLQR_ClampLow_1_counter = 1;
			return create_RESULT_CONT();
		} else {
			(state)->en_AcrobotSwingUpLQR_ClampLow_1_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum AcrobotSwingUpLQR_j_mode(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output) {
		if (!(memorystate)->near_upright) {
			(*state).state = create_STATES_stm_ref0_SwingUp();
			(*state).status = create_STATUS_ENTER_STATE();
			return create_RESULT_CONT();
		} else if ((memorystate)->near_upright) {
			(*state).state = create_STATES_stm_ref0_Balance();
			(*state).status = create_STATUS_ENTER_STATE();
			return create_RESULT_CONT();
		} else {
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum en_AcrobotSwingUpLQR_Output_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_Output.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_Output_1_counter == 0 ) {
			{
				pthread_barrier_wait(&output->can_write);
				output->value = create_stm_ref0_output_ApplyTorque((memory)->tau);
				pthread_barrier_wait(&output->can_read);
			}
			(*state).en_AcrobotSwingUpLQR_Output_1_counter = 1;
			return create_RESULT_CONT();
		} else {
			(state)->en_AcrobotSwingUpLQR_Output_1_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum en_AcrobotSwingUpLQR_InRange_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_InRange.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_InRange_1_counter == 0 ) {
			(*memory).tau = (memory)->tau_raw;
			(*state).en_AcrobotSwingUpLQR_InRange_1_counter = 1;
			return create_RESULT_CONT();
		} else {
			(state)->en_AcrobotSwingUpLQR_InRange_1_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUp_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_SwingUp.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 0 ) {
			(*memory).KE = (0.5 * ((((((memory)->M11 * (memory)->dq1) * (memory)->dq1) + (((2.0 * (memory)->M12) * (memory)->dq1) * (memory)->dq2)) + (((memory)->M22 * (memory)->dq2) * (memory)->dq2))));
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 1;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 1 ) {
			(*memory).PE = ((((-(memory)->m1 * (memory)->g) * (memory)->lc1) * (memory)->cos_q1) - (((memory)->m2 * (memory)->g) * ((((memory)->l1 * (memory)->cos_q1) + ((memory)->lc2 * (memory)->cos_q1_q2)))));
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 2;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 2 ) {
			(*memory).E = ((memory)->PE + (memory)->KE);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 3;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 3 ) {
			(*memory).E_desired = (((((memory)->m1 * (memory)->lc1) + ((memory)->m2 * (((memory)->l1 + (memory)->lc2))))) * (memory)->g);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 4;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 4 ) {
			(*memory).E_tilde = ((memory)->E - (memory)->E_desired);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 5;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 5 ) {
			(*memory).u_e = ((-(memory)->k_e * (memory)->E_tilde) * (memory)->dq2);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 6;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 6 ) {
			(*memory).y = ((-(memory)->k_p * (memory)->q2) - ((memory)->k_d * (memory)->dq2));
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 7;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 7 ) {
			(*memory).C1 = ((((((-(memory)->m2 * (memory)->l1) * (memory)->lc2) * (memory)->sin_q2) * ((((2.0 * (memory)->dq1) * (memory)->dq2) + ((memory)->dq2 * (memory)->dq2)))) + ((((((memory)->m1 * (memory)->lc1) + ((memory)->m2 * (memory)->l1))) * (memory)->g) * (memory)->sin_q1)) + ((((memory)->m2 * (memory)->lc2) * (memory)->g) * (memory)->sin_q1_q2));
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 8;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 8 ) {
			(*memory).C2 = ((((((memory)->m2 * (memory)->l1) * (memory)->lc2) * (memory)->sin_q2) * (((memory)->dq1 * (memory)->dq1))) + ((((memory)->m2 * (memory)->lc2) * (memory)->g) * (memory)->sin_q1_q2));
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 9;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 9 ) {
			(*memory).a2 = (-(memory)->M12 / (memory)->det);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 10;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 10 ) {
			(*memory).a3 = ((memory)->M11 / (memory)->det);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 11;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 11 ) {
			(*memory).u_p = ((((((memory)->a2 * (memory)->C1) + (memory)->y)) / (memory)->a3) + (memory)->C2);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 12;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUp_1_counter == 12 ) {
			(*memory).tau_raw = ((memory)->u_e + (memory)->u_p);
			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 13;
			return create_RESULT_CONT();
		} else {
			(state)->en_AcrobotSwingUpLQR_SwingUp_1_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum tr_AcrobotSwingUpLQR_t_output_to_wait(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running transition action of transition AcrobotSwingUpLQR_t_output_to_wait.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->tr_AcrobotSwingUpLQR_t_output_to_wait_counter == 0 ) {
			(*state).tr_AcrobotSwingUpLQR_t_output_to_wait_counter = 1;
			return create_RESULT_WAIT();
		} else {
			(state)->tr_AcrobotSwingUpLQR_t_output_to_wait_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum en_AcrobotSwingUpLQR_ClampHigh_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_ClampHigh.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_ClampHigh_1_counter == 0 ) {
			(*memory).tau = (memory)->TAU_MAX;
			(*state).en_AcrobotSwingUpLQR_ClampHigh_1_counter = 1;
			return create_RESULT_CONT();
		} else {
			(state)->en_AcrobotSwingUpLQR_ClampHigh_1_done = true;
			return create_RESULT_CONT();
		}
	}
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "	Started step of controller ctrl_ref0");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
	}
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "		Running step of state machine AcrobotSwingUpLQR");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if ((*state).state.type == create_STATES_stm_ref0_NONE().type) {
			{
				char _s0[256];
				sprintf(_s0, "%s", "		Executing initial junction of AcrobotSwingUpLQR");
				fprintf(log_file, "DEBUG: %s\n", _s0);
			}
			{
				(*state).state = create_STATES_stm_ref0_Wait();
			}
			return create_RESULT_CONT();
		}
		else if ((*state).state.type == create_STATES_stm_ref0_Wait().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state Wait");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		{
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state Wait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state Wait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if ((inputstate)->sensorUpdate) {
		     	     			(*memorystate).su = (inputstate)->sensorUpdate_value;
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_recv_sensors();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state Wait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state Wait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_recv_sensors().type
		     	     		     ) {
		     	     			if (!(state)->tr_AcrobotSwingUpLQR_t_recv_sensors_done) {
		     	     				RESULT_Enum _ret_;
		     	     				_ret_ = tr_AcrobotSwingUpLQR_t_recv_sensors(state, inputstate, memorystate, output);
		     	     				return _ret_;
		     	     			} else {
		     	     				(*state).state = create_STATES_stm_ref0_Compute();
		     	     				(*state).status = create_STATUS_ENTER_STATE();
		     	     				(*state).tr_AcrobotSwingUpLQR_t_recv_sensors_done = false;
		     	     				(*state).tr_AcrobotSwingUpLQR_t_recv_sensors_counter = 0;
		     	     				return create_RESULT_CONT();
		     	     			}
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State Wait is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_Compute().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state Compute");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_Compute_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_Compute_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_Compute_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_Compute_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state Compute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state Compute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if (true) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_to_mode();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state Compute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state Compute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_to_mode().type
		     	     		     ) {
		     	     			RESULT_Enum _ret_;
		     	     			_ret_ = AcrobotSwingUpLQR_j_mode(state, inputstate, memorystate, output);
		     	     			return _ret_;
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State Compute is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_SwingUp().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state SwingUp");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_SwingUp_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_SwingUp_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_SwingUp_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_SwingUp_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state SwingUp");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state SwingUp");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if (true) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_to_clamp();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state SwingUp");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state SwingUp");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_to_clamp().type
		     	     		     ) {
		     	     			RESULT_Enum _ret_;
		     	     			_ret_ = AcrobotSwingUpLQR_j_clamp(state, inputstate, memorystate, output);
		     	     			return _ret_;
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State SwingUp is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_Balance().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state Balance");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_Balance_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_Balance_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_Balance_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_Balance_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state Balance");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state Balance");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if (true) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_to_clamp();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state Balance");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state Balance");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_to_clamp().type
		     	     		     ) {
		     	     			RESULT_Enum _ret_;
		     	     			_ret_ = AcrobotSwingUpLQR_j_clamp(state, inputstate, memorystate, output);
		     	     			return _ret_;
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State Balance is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_ClampHigh().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state ClampHigh");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_ClampHigh_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_ClampHigh_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_ClampHigh_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_ClampHigh_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state ClampHigh");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state ClampHigh");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if (true) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_high_to_output();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state ClampHigh");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state ClampHigh");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_high_to_output().type
		     	     		     ) {
		     	     			(*state).state = create_STATES_stm_ref0_Output();
		     	     			(*state).status = create_STATUS_ENTER_STATE();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State ClampHigh is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_ClampLow().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state ClampLow");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_ClampLow_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_ClampLow_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_ClampLow_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_ClampLow_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state ClampLow");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state ClampLow");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if (true) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_low_to_output();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state ClampLow");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state ClampLow");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_low_to_output().type
		     	     		     ) {
		     	     			(*state).state = create_STATES_stm_ref0_Output();
		     	     			(*state).status = create_STATUS_ENTER_STATE();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State ClampLow is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_InRange().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state InRange");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_InRange_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_InRange_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_InRange_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_InRange_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state InRange");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state InRange");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if (true) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_range_to_output();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state InRange");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state InRange");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_range_to_output().type
		     	     		     ) {
		     	     			(*state).state = create_STATES_stm_ref0_Output();
		     	     			(*state).status = create_STATUS_ENTER_STATE();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State InRange is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_Output().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state Output");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_Output_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_Output_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_Output_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_Output_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state Output");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXECUTE_STATE();
		     	     	{
		     	     		(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_NONE();
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXECUTE_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Executing state Output");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if (true) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_output_to_wait();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else {
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	} else {
		     	     		return create_RESULT_CONT();
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting children of state Output");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state Output");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_output_to_wait().type
		     	     		     ) {
		     	     			if (!(state)->tr_AcrobotSwingUpLQR_t_output_to_wait_done) {
		     	     				RESULT_Enum _ret_;
		     	     				_ret_ = tr_AcrobotSwingUpLQR_t_output_to_wait(state, inputstate, memorystate, output);
		     	     				return _ret_;
		     	     			} else {
		     	     				(*state).state = create_STATES_stm_ref0_Wait();
		     	     				(*state).status = create_STATUS_ENTER_STATE();
		     	     				(*state).tr_AcrobotSwingUpLQR_t_output_to_wait_done = false;
		     	     				(*state).tr_AcrobotSwingUpLQR_t_output_to_wait_counter = 0;
		     	     				return create_RESULT_CONT();
		     	     			}
		     	     		} else {
		     	     			(*state).status = create_STATUS_INACTIVE();
		     	     			(*state).state = create_STATES_stm_ref0_NONE();
		     	     			return create_RESULT_CONT();
		     	     		}
		     	     	}
		     	     }
		     	else if ((*state).status.type == create_STATUS_INACTIVE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		State Output is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
	}
	RESULT_Enum en_AcrobotSwingUpLQR_Balance_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_Balance.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_Balance_1_counter == 0 ) {
			(*memory).tau_raw = -((((((memory)->K0 * (memory)->x_err0) + ((memory)->K1 * (memory)->x_err1)) + ((memory)->K2 * (memory)->x_err2)) + ((memory)->K3 * (memory)->x_err3)));
			(*state).en_AcrobotSwingUpLQR_Balance_1_counter = 1;
			return create_RESULT_CONT();
		} else {
			(state)->en_AcrobotSwingUpLQR_Balance_1_done = true;
			return create_RESULT_CONT();
		}
	}
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value) {
		if (value->type == STATES_stm_ref0_NONE) {
			return "NONE";
		}
		else if (value->type == STATES_stm_ref0_Wait) {
		     	return "Wait";
		     }
		else if (value->type == STATES_stm_ref0_Compute) {
		     	return "Compute";
		     }
		else if (value->type == STATES_stm_ref0_SwingUp) {
		     	return "SwingUp";
		     }
		else if (value->type == STATES_stm_ref0_Balance) {
		     	return "Balance";
		     }
		else if (value->type == STATES_stm_ref0_ClampHigh) {
		     	return "ClampHigh";
		     }
		else if (value->type == STATES_stm_ref0_ClampLow) {
		     	return "ClampLow";
		     }
		else if (value->type == STATES_stm_ref0_InRange) {
		     	return "InRange";
		     }
		else if (value->type == STATES_stm_ref0_Output) {
		     	return "Output";
		     }
	}
	char* print_stm_ref0_state(struct stm_ref0_state* state) {
		char* temp1_;
		temp1_ = print_STATES_stm_ref0(&(state)->state);
		char* temp2_;
		temp2_ = print_STATUS(&(state)->status);
		char* aux1_ = concat(temp1_, " (");
		char* aux2_ = concat(aux1_, temp2_);
		char* aux3_ = concat(aux2_, ")");
		free(aux1_);
		free(aux2_);
		return aux3_;
	}
	RESULT_Enum tr_AcrobotSwingUpLQR_t_recv_sensors(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running transition action of transition AcrobotSwingUpLQR_t_recv_sensors.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->tr_AcrobotSwingUpLQR_t_recv_sensors_counter == 0 ) {
			(*memory).shoulder_angle = ((memory)->su).shoulderAngle;
			(*state).tr_AcrobotSwingUpLQR_t_recv_sensors_counter = 1;
			return create_RESULT_CONT();
		} else if (	(state)->tr_AcrobotSwingUpLQR_t_recv_sensors_counter == 1 ) {
			(*memory).shoulder_velocity = ((memory)->su).shoulderVelocity;
			(*state).tr_AcrobotSwingUpLQR_t_recv_sensors_counter = 2;
			return create_RESULT_CONT();
		} else if (	(state)->tr_AcrobotSwingUpLQR_t_recv_sensors_counter == 2 ) {
			(*memory).elbow_angle = ((memory)->su).elbowAngle;
			(*state).tr_AcrobotSwingUpLQR_t_recv_sensors_counter = 3;
			return create_RESULT_CONT();
		} else if (	(state)->tr_AcrobotSwingUpLQR_t_recv_sensors_counter == 3 ) {
			(*memory).elbow_velocity = ((memory)->su).elbowVelocity;
			(*state).tr_AcrobotSwingUpLQR_t_recv_sensors_counter = 4;
			return create_RESULT_CONT();
		} else {
			(state)->tr_AcrobotSwingUpLQR_t_recv_sensors_done = true;
			return create_RESULT_CONT();
		}
	}
