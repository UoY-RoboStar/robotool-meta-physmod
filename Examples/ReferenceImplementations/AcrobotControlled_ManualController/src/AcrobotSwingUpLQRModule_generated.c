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

// MANUAL: Torque saturation (matches Drake's ±20 limit)
static inline float clamp_torque(float v) {
    if (v > 20.0f) return 20.0f;
    if (v < -20.0f) return -20.0f;
    return v;
}

// MANUAL: Wrap angle to [-pi, pi] range
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
static inline float wrap_angle(float v) {
    while (v > M_PI) v -= 2.0f * M_PI;
    while (v < -M_PI) v += 2.0f * M_PI;
    return v;
}


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
	STATES_stm_ref0_SwingUpWait,
	STATES_stm_ref0_SwingUpCompute,
	STATES_stm_ref0_BalanceWait,
	STATES_stm_ref0_BalanceCompute,
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
STATES_stm_ref0_Enum create_STATES_stm_ref0_SwingUpWait() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_SwingUpWait;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_SwingUpCompute() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_SwingUpCompute;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_BalanceWait() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_BalanceWait;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
STATES_stm_ref0_Enum create_STATES_stm_ref0_BalanceCompute() {
	STATES_stm_ref0_Data data;

	STATES_stm_ref0_Type type = STATES_stm_ref0_BalanceCompute;
	
	STATES_stm_ref0_Enum aux = (STATES_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
/* Representation of enum TRANSITIONS_stm_ref0 */

typedef enum {
	TRANSITIONS_stm_ref0_NONE,
	TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_swing,
	TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_balance,
	TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_balance,
	TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_swing,
	TRANSITIONS_stm_ref0_stm_ref0_t_init,
	TRANSITIONS_stm_ref0_stm_ref0_t_balance_update,
	TRANSITIONS_stm_ref0_stm_ref0_t_swing_update,
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
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_swing() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_swing;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_balance() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_balance;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_balance() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_balance;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_swing() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_swing;
	
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
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_update() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_balance_update;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}
TRANSITIONS_stm_ref0_Enum create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_update() {
	TRANSITIONS_stm_ref0_Data data;

	TRANSITIONS_stm_ref0_Type type = TRANSITIONS_stm_ref0_stm_ref0_t_swing_update;
	
	TRANSITIONS_stm_ref0_Enum aux = (TRANSITIONS_stm_ref0_Enum) {
		.type = type,
		.data = data
	};
	
	return aux;	
}

/* Representation of record AcrobotStateUpdate - moved before first use */
struct AcrobotStateUpdate {
	float dtheta1;
	float theta1;
	float theta2;
	float dtheta2;
};

/* Representation of enum M_AcrobotSwingUpLQRModule_input */

typedef enum {
	M_AcrobotSwingUpLQRModule_input_stateUpdate,
	M_AcrobotSwingUpLQRModule_input__done_,
	M_AcrobotSwingUpLQRModule_input__terminate_,
} M_AcrobotSwingUpLQRModule_input_Type;

typedef struct {
	struct AcrobotStateUpdate v1;
} M_AcrobotSwingUpLQRModule_input_stateUpdate_Data;

typedef union {
	M_AcrobotSwingUpLQRModule_input_stateUpdate_Data stateUpdate;
} M_AcrobotSwingUpLQRModule_input_Data;

typedef struct {
	M_AcrobotSwingUpLQRModule_input_Type type;
	M_AcrobotSwingUpLQRModule_input_Data data;
} M_AcrobotSwingUpLQRModule_input_Enum;

M_AcrobotSwingUpLQRModule_input_Enum create_M_AcrobotSwingUpLQRModule_input_stateUpdate(struct AcrobotStateUpdate v1) {
	M_AcrobotSwingUpLQRModule_input_Data data;
		
	data.stateUpdate.v1 = v1;	

	M_AcrobotSwingUpLQRModule_input_Type type = M_AcrobotSwingUpLQRModule_input_stateUpdate;
	
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
/* Representation of enum C_ctrl_ref0_input */

typedef enum {
	C_ctrl_ref0_input_stateUpdate,
	C_ctrl_ref0_input__done_,
	C_ctrl_ref0_input__terminate_,
} C_ctrl_ref0_input_Type;

typedef struct {
	struct AcrobotStateUpdate v1;
} C_ctrl_ref0_input_stateUpdate_Data;

typedef union {
	C_ctrl_ref0_input_stateUpdate_Data stateUpdate;
} C_ctrl_ref0_input_Data;

typedef struct {
	C_ctrl_ref0_input_Type type;
	C_ctrl_ref0_input_Data data;
} C_ctrl_ref0_input_Enum;

C_ctrl_ref0_input_Enum create_C_ctrl_ref0_input_stateUpdate(struct AcrobotStateUpdate v1) {
	C_ctrl_ref0_input_Data data;
		
	data.stateUpdate.v1 = v1;	

	C_ctrl_ref0_input_Type type = C_ctrl_ref0_input_stateUpdate;
	
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
/* Representation of enum stm_ref0_input */

typedef enum {
	stm_ref0_input_stateUpdate,
	stm_ref0_input__done_,
	stm_ref0_input__terminate_,
} stm_ref0_input_Type;

typedef struct {
	struct AcrobotStateUpdate v1;
} stm_ref0_input_stateUpdate_Data;

typedef union {
	stm_ref0_input_stateUpdate_Data stateUpdate;
} stm_ref0_input_Data;

typedef struct {
	stm_ref0_input_Type type;
	stm_ref0_input_Data data;
} stm_ref0_input_Enum;

stm_ref0_input_Enum create_stm_ref0_input_stateUpdate(struct AcrobotStateUpdate v1) {
	stm_ref0_input_Data data;
		
	data.stateUpdate.v1 = v1;	

	stm_ref0_input_Type type = stm_ref0_input_stateUpdate;
	
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

/* Representation of record AcrobotStateUpdate - defined earlier in file */

/* Representation of record stm_ref0_state */
struct stm_ref0_state {
	bool done;
	STATES_stm_ref0_Enum state;
	STATES_stm_ref0_Enum target_state;
	STATUS_Enum status;
	bool en_AcrobotSwingUpLQR_BalanceCompute_1_done;
	int en_AcrobotSwingUpLQR_BalanceCompute_1_counter;
	bool en_AcrobotSwingUpLQR_SwingUpCompute_1_done;
	int en_AcrobotSwingUpLQR_SwingUpCompute_1_counter;
	bool tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_done;
	int tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_counter;
	bool tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_done;
	int tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_counter;
	bool tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_done;
	int tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_counter;
	bool tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_done;
	int tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_counter;
};
/* Representation of record stm_ref0_inputstate */
struct stm_ref0_inputstate {
	bool stateUpdate;
	struct AcrobotStateUpdate stateUpdate_value;
	int _clock_C;
	TRANSITIONS_stm_ref0_Enum _transition_;
};
/* Representation of record stm_ref0_memory */
struct stm_ref0_memory {
	float S30;
	float cost;
	float k_d;
	float S32;
	float M11;
	float S31;
	struct AcrobotStateUpdate su;
	float Ic1;
	float K2;
	float S12;
	float theta2;
	float k_p;
	float tau;
	float E;
	float S00;
	float S02;
	float S22;
	float K3;
	float u_e;
	float a2;
	float Ic2;
	float PE;
	float K0;
	float a3;
	float S10;
	float u_p;
	float E_tilde;
	float k_e;
	float lc1;
	float M22;
	float m1;
	float detM;
	float lc2;
	float K1;
	float S03;
	float KE;
	float M12;
	float x3;
	float x1;
	float C2;
	float g;
	float C1;
	float x0;
	float l1;
	float l2;
	float balancing_threshold;
	float S33;
	float S13;
	float dtheta2;
	float S23;
	float x2;
	float m2;
	float S01;
	float y;
	float S11;
	float dtheta1;
	float PI;
	float theta1;
	float E_des;
	float S20;
	float S21;
};

typedef struct {
	pthread_barrier_t can_write, can_read;
	M_AcrobotSwingUpLQRModule_input_Enum value;
} M_AcrobotSwingUpLQRModule_input_Enum_Channel;
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
	C_ctrl_ref0_output_Enum value;
} C_ctrl_ref0_output_Enum_Channel;
typedef struct {
	pthread_barrier_t can_write, can_read;
	stm_ref0_output_Enum value;
} stm_ref0_output_Enum_Channel;
typedef struct {
	pthread_barrier_t can_write, can_read;
	C_ctrl_ref0_input_Enum value;
} C_ctrl_ref0_input_Enum_Channel;

typedef struct {
	M_AcrobotSwingUpLQRModule_output_Enum_Channel* end_AcrobotSwingUpLQRModule;
	M_AcrobotSwingUpLQRModule_input_Enum_Channel* start_AcrobotSwingUpLQRModule;
} control_Channels;

/* Declaration of function signatures */
	float acrobot_cos(float x);
	float acrobot_sin(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_BalanceCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUpCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

void *control(void *arg) {
	control_Channels* channels = (control_Channels*) arg;
	M_AcrobotSwingUpLQRModule_output_Enum_Channel* end_AcrobotSwingUpLQRModule = channels->end_AcrobotSwingUpLQRModule;
	M_AcrobotSwingUpLQRModule_input_Enum_Channel* start_AcrobotSwingUpLQRModule = channels->start_AcrobotSwingUpLQRModule;
{
	bool terminate__ = false;
	int cycle_count = 0;
	while (!terminate__) {
		{
		bool inputdone = false;
		// MANUAL: Accumulate sensor readings from platform via registerRead()
		struct AcrobotStateUpdate _value_ = (struct AcrobotStateUpdate) {
			.dtheta1 = 0.0,
			.theta1 = 0.0,
			.theta2 = 0.0,
			.dtheta2 = 0.0
		};
		while (!inputdone) {
			int input_type;
			double input_value;
			if (!registerRead(&input_type, &input_value)) {
				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
				start_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_input__terminate_();
				pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
				terminate__ = true;
				inputdone = true;
				break;
			}
			switch (input_type) {
				case INPUT_SHOULDER_ANGLE:
					// ShoulderEncoder = TIP joint = Drake's theta2
					// MANUAL: Wrap angle to [-pi, pi]
					_value_.theta2 = wrap_angle((float)input_value);
					break;
				case INPUT_SHOULDER_VELOCITY:
					_value_.dtheta2 = (float)input_value;
					break;
				case INPUT_ELBOW_ANGLE:
					// ElbowEncoder = BASE joint = Drake's theta1
					// MANUAL: Wrap angle to [-pi, pi]
					_value_.theta1 = wrap_angle((float)input_value);
					break;
				case INPUT_ELBOW_VELOCITY:
					_value_.dtheta1 = (float)input_value;
					break;
				case INPUT_DONE:
					// All sensors received, send stateUpdate event
					// DEBUG: Print wrapped values every 100 cycles
					if (cycle_count % 100 == 0) {
						float x0_dbg = _value_.theta1 - 3.14159265f;
						float cost_dbg = x0_dbg * x0_dbg * 16620.0f; // Approximate dominant term
						fprintf(stderr, "[DEBUG] cycle=%d: theta1=%.3f, theta2=%.3f, x0=%.3f, cost_approx=%.1f\n",
							cycle_count, _value_.theta1, _value_.theta2, x0_dbg, cost_dbg);
					}
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
					start_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_input_stateUpdate(_value_);
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
					// Then send done
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
					start_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_input__done_();
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
					inputdone = true;
					break;
				case INPUT_TERMINATE:
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_write);
					start_AcrobotSwingUpLQRModule->value = create_M_AcrobotSwingUpLQRModule_input__terminate_();
					pthread_barrier_wait(&start_AcrobotSwingUpLQRModule->can_read);
					terminate__ = true;
					inputdone = true;
					break;
				default:
					break;
			}
		}
		}
		{
			bool outputdone = false;
			while (!outputdone) {
				M_AcrobotSwingUpLQRModule_output_Enum _output_;
				{	
					pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_write);
					pthread_barrier_wait(&end_AcrobotSwingUpLQRModule->can_read);
					_output_ = end_AcrobotSwingUpLQRModule->value;	
				}
				if (_output_.type == M_AcrobotSwingUpLQRModule_output_ApplyTorque) {
					float _aux1_ = _output_.data.ApplyTorque.v1;	
					// MANUAL: Apply torque saturation and send to orchestrator
					_aux1_ = clamp_torque(_aux1_);
					registerWrite(&(OperationData){OUTPUT_CONTROL_IN, 1, {(double)_aux1_}, (double)cycle_count * 0.005});
				}
				else if (_output_.type == M_AcrobotSwingUpLQRModule_output__done_) {
				     	// MANUAL: Send done signal to orchestrator
				     	registerWrite(&(OperationData){OUTPUT_DONE, 0, {0.0}, 0.0});
				     	outputdone = true;
				     }
			}
			
		}
		cycle_count++;
	}
}
}
typedef struct {
	C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0;
	stm_ref0_output_Enum_Channel* end_stm_ref0;
	C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0;
	stm_ref0_input_Enum_Channel* start_stm_ref0;
} ctrl_ctrl_ref0_thread_Channels;

/* Declaration of function signatures */
	float acrobot_cos(float x);
	float acrobot_sin(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_BalanceCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUpCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

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
				if (_input_.type == C_ctrl_ref0_input_stateUpdate) {
					struct AcrobotStateUpdate _aux1_ = _input_.data.stateUpdate.v1;	
					{
						pthread_barrier_wait(&start_stm_ref0->can_write);
						start_stm_ref0->value = create_stm_ref0_input_stateUpdate(_aux1_);
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
typedef struct {
	stm_ref0_input_Enum_Channel* start_stm_ref0;
	stm_ref0_output_Enum_Channel* end_stm_ref0;
} stm_stm_ref0_Channels;

/* Declaration of function signatures */
	float acrobot_cos(float x);
	float acrobot_sin(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_BalanceCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUpCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

void *stm_stm_ref0(void *arg) {
	stm_stm_ref0_Channels* channels = (stm_stm_ref0_Channels*) arg;
	stm_ref0_input_Enum_Channel* start_stm_ref0 = channels->start_stm_ref0;
	stm_ref0_output_Enum_Channel* end_stm_ref0 = channels->end_stm_ref0;
{
	// state machine variable declarations;
	struct stm_ref0_inputstate inputstate = (struct stm_ref0_inputstate) {
	                                        	.stateUpdate = false,
	                                        	.stateUpdate_value = (struct AcrobotStateUpdate) {
	                                        		.dtheta1 = 0.0,
	                                        		.theta1 = 0.0,
	                                        		.theta2 = 0.0,
	                                        		.dtheta2 = 0.0
	                                        	},
	                                        	._clock_C = 0,
	                                        	._transition_ = create_TRANSITIONS_stm_ref0_NONE()
	                                        };
	struct stm_ref0_state state = (struct stm_ref0_state) {
	                              	.done = false,
	                              	.state = create_STATES_stm_ref0_NONE(),
	                              	.target_state = create_STATES_stm_ref0_NONE(),
	                              	.status = create_STATUS_ENTER_STATE(),
	                              	.en_AcrobotSwingUpLQR_BalanceCompute_1_done = false,
	                              	.en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 0,
	                              	.en_AcrobotSwingUpLQR_SwingUpCompute_1_done = false,
	                              	.en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 0,
	                              	.tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_done = false,
	                              	.tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_counter = 0,
	                              	.tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_done = false,
	                              	.tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_counter = 0,
	                              	.tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_done = false,
	                              	.tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_counter = 0,
	                              	.tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_done = false,
	                              	.tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_counter = 0
	                              };
	struct stm_ref0_memory memorystate = (struct stm_ref0_memory) {
	                                     	.S30 = 3571.581,
	                                     	.cost = 0.0,
	                                     	.k_d = 5.0,
	                                     	.S32 = 1556.5061,
	                                     	.M11 = 0.0,
	                                     	.S31 = 1608.5416,
	                                     	.su = (struct AcrobotStateUpdate) {
	                                     		.dtheta1 = 0.0,
	                                     		.theta1 = 0.0,
	                                     		.theta2 = 0.0,
	                                     		.dtheta2 = 0.0
	                                     	},
	                                     	.Ic1 = 0.083,
	                                     	.K2 = -119.72,
	                                     	.S12 = 3256.4028,
	                                     	.theta2 = 0.0,
	                                     	.k_p = 50.0,
	                                     	.tau = 0.0,
	                                     	.E = 0.0,
	                                     	.S00 = 16620.607,
	                                     	.S02 = 7240.1235,
	                                     	.S22 = 3154.7305,
	                                     	.K3 = -56.83,
	                                     	.u_e = 0.0,
	                                     	.a2 = 0.0,
	                                     	.Ic2 = 0.333,
	                                     	.PE = 0.0,
	                                     	.K0 = -278.44,
	                                     	.a3 = 0.0,
	                                     	.S10 = 7470.1875,
	                                     	.u_p = 0.0,
	                                     	.E_tilde = 0.0,
	                                     	.k_e = 5.0,
	                                     	.lc1 = 0.5,
	                                     	.M22 = 0.0,
	                                     	.m1 = 1.0,
	                                     	.detM = 0.0,
	                                     	.lc2 = 1.0,
	                                     	.K1 = -112.29,
	                                     	.S03 = 3571.581,
	                                     	.KE = 0.0,
	                                     	.M12 = 0.0,
	                                     	.x3 = 0.0,
	                                     	.x1 = 0.0,
	                                     	.C2 = 0.0,
	                                     	.g = 9.81,
	                                     	.C1 = 0.0,
	                                     	.x0 = 0.0,
	                                     	.l1 = 1.0,
	                                     	.l2 = 2.0,
	                                     	.balancing_threshold = 1000.0,
	                                     	.S33 = 768.33307,
	                                     	.S13 = 1608.5416,
	                                     	.dtheta2 = 0.0,
	                                     	.S23 = 1556.5061,
	                                     	.x2 = 0.0,
	                                     	.m2 = 1.0,
	                                     	.S01 = 7470.1875,
	                                     	.y = 0.0,
	                                     	.S11 = 3374.4365,
	                                     	.dtheta1 = 0.0,
	                                     	.PI = 3.1415927,
	                                     	.theta1 = 0.0,
	                                     	.E_des = 0.0,
	                                     	.S20 = 7240.1235,
	                                     	.S21 = 3256.4028
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
				if (_input_.type == stm_ref0_input_stateUpdate) {
					struct AcrobotStateUpdate _aux_ = _input_.data.stateUpdate.v1;	
					(inputstate).stateUpdate = true;
					(inputstate).stateUpdate_value = _aux_;
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
		(inputstate).stateUpdate = false;
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
	float acrobot_cos(float x);
	float acrobot_sin(float x);
	char* print_STATUS(STATUS_Enum* value);
	void mod_AcrobotSwingUpLQRModule_step(C_ctrl_ref0_input_Enum_Channel* start_ctrl_ref0
	                                      , C_ctrl_ref0_output_Enum_Channel* end_ctrl_ref0);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum en_AcrobotSwingUpLQR_BalanceCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	void ctrl_ctrl_ref0_step(stm_ref0_input_Enum_Channel* start_stm_ref0
	                         , stm_ref0_output_Enum_Channel* end_stm_ref0);
	char* print_stm_ref0_state(struct stm_ref0_state* state);
	RESULT_Enum stm_stm_ref0_step(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memorystate, stm_ref0_output_Enum_Channel* output);
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value);
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUpCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output);

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
				if (_input_.type == M_AcrobotSwingUpLQRModule_input_stateUpdate) {
					struct AcrobotStateUpdate _aux1_ = _input_.data.stateUpdate.v1;	
					{
						pthread_barrier_wait(&start_ctrl_ref0->can_write);
						start_ctrl_ref0->value = create_C_ctrl_ref0_input_stateUpdate(_aux1_);
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
	pthread_t ctrl_ctrl_ref0_thread_id;
	ctrl_ctrl_ref0_thread_Channels* ctrl_ctrl_ref0_thread_channels = (ctrl_ctrl_ref0_thread_Channels*)malloc(sizeof(ctrl_ctrl_ref0_thread_Channels));
	
	ctrl_ctrl_ref0_thread_channels->start_ctrl_ref0 = start_ctrl_ref0;
	ctrl_ctrl_ref0_thread_channels->end_stm_ref0 = end_stm_ref0;
	ctrl_ctrl_ref0_thread_channels->end_ctrl_ref0 = end_ctrl_ref0;
	ctrl_ctrl_ref0_thread_channels->start_stm_ref0 = start_stm_ref0;
	
	status = pthread_create(&ctrl_ctrl_ref0_thread_id, NULL, ctrl_ctrl_ref0_thread, ctrl_ctrl_ref0_thread_channels);
	if (status != 0)
			err_abort(status, "Create ctrl_ctrl_ref0_thread thread");
	pthread_t stm_stm_ref0_id;
	stm_stm_ref0_Channels* stm_stm_ref0_channels = (stm_stm_ref0_Channels*)malloc(sizeof(stm_stm_ref0_Channels));
	
	stm_stm_ref0_channels->start_stm_ref0 = start_stm_ref0;
	stm_stm_ref0_channels->end_stm_ref0 = end_stm_ref0;
	
	status = pthread_create(&stm_stm_ref0_id, NULL, stm_stm_ref0, stm_stm_ref0_channels);
	if (status != 0)
			err_abort(status, "Create stm_stm_ref0 thread");
		
	status = pthread_join(control_id, NULL);
	if (status != 0)
			err_abort(status, "Join control thread");		
	status = pthread_join(mod_AcrobotSwingUpLQRModule_thread_id, NULL);
	if (status != 0)
			err_abort(status, "Join mod_AcrobotSwingUpLQRModule_thread thread");		
	status = pthread_join(ctrl_ctrl_ref0_thread_id, NULL);
	if (status != 0)
			err_abort(status, "Join ctrl_ctrl_ref0_thread thread");		
	status = pthread_join(stm_stm_ref0_id, NULL);
	if (status != 0)
			err_abort(status, "Join stm_stm_ref0 thread");		
	// Free channels;
	free(start_AcrobotSwingUpLQRModule);
	free(end_AcrobotSwingUpLQRModule);
	free(start_ctrl_ref0);
	free(end_ctrl_ref0);
	free(start_stm_ref0);
	free(end_stm_ref0);
	free(control_channels);
	free(mod_AcrobotSwingUpLQRModule_thread_channels);
	free(ctrl_ctrl_ref0_thread_channels);
	free(stm_stm_ref0_channels);
	
	fclose(log_file);
}

	float acrobot_cos(float x) {
		return cosf(x);
	}
	float acrobot_sin(float x) {
		return sinf(x);
	}
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
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running transition action of transition AcrobotSwingUpLQR_t_balance_compute_to_swing.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_counter == 0 ) {
			(*state).tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_counter = 1;
			return create_RESULT_WAIT();
		} else {
			(state)->tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum tr_AcrobotSwingUpLQR_t_balance_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running transition action of transition AcrobotSwingUpLQR_t_balance_compute_to_balance.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_counter == 0 ) {
			(*state).tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_counter = 1;
			return create_RESULT_WAIT();
		} else {
			(state)->tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum en_AcrobotSwingUpLQR_BalanceCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_BalanceCompute.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 0 ) {
			(*memory).theta1 = ((memory)->su).theta1;
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 1;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 1 ) {
			(*memory).theta2 = ((memory)->su).theta2;
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 2;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 2 ) {
			(*memory).dtheta1 = ((memory)->su).dtheta1;
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 3;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 3 ) {
			(*memory).dtheta2 = ((memory)->su).dtheta2;
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 4;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 4 ) {
			(*memory).x0 = ((memory)->theta1 - (memory)->PI);
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 5;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 5 ) {
			(*memory).x1 = (memory)->theta2;
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 6;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 6 ) {
			(*memory).x2 = (memory)->dtheta1;
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 7;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 7 ) {
			(*memory).x3 = (memory)->dtheta2;
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 8;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 8 ) {
			(*memory).cost = (((((memory)->x0 * ((((((memory)->S00 * (memory)->x0) + ((memory)->S01 * (memory)->x1)) + ((memory)->S02 * (memory)->x2)) + ((memory)->S03 * (memory)->x3)))) + ((memory)->x1 * ((((((memory)->S10 * (memory)->x0) + ((memory)->S11 * (memory)->x1)) + ((memory)->S12 * (memory)->x2)) + ((memory)->S13 * (memory)->x3))))) + ((memory)->x2 * ((((((memory)->S20 * (memory)->x0) + ((memory)->S21 * (memory)->x1)) + ((memory)->S22 * (memory)->x2)) + ((memory)->S23 * (memory)->x3))))) + ((memory)->x3 * ((((((memory)->S30 * (memory)->x0) + ((memory)->S31 * (memory)->x1)) + ((memory)->S32 * (memory)->x2)) + ((memory)->S33 * (memory)->x3)))));
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 9;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 9 ) {
			(*memory).tau = -((((((memory)->K0 * (memory)->x0) + ((memory)->K1 * (memory)->x1)) + ((memory)->K2 * (memory)->x2)) + ((memory)->K3 * (memory)->x3)));
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 10;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 10 ) {
			{
				pthread_barrier_wait(&output->can_write);
				output->value = create_stm_ref0_output_ApplyTorque((memory)->tau);
				pthread_barrier_wait(&output->can_read);
			}
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 11;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_counter == 11 ) {
			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 12;
			return create_RESULT_WAIT();
		} else {
			(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_done = true;
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
				(*state).state = create_STATES_stm_ref0_SwingUpWait();
			}
			return create_RESULT_CONT();
		}
		else if ((*state).state.type == create_STATES_stm_ref0_SwingUpWait().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state SwingUpWait");
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
		     	     		sprintf(_s0, "%s", "		Entering children of state SwingUpWait");
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
		     	     		sprintf(_s0, "%s", "		Executing state SwingUpWait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if ((inputstate)->stateUpdate) {
		     	     			(*memorystate).su = (inputstate)->stateUpdate_value;
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_update();
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
		     	     		sprintf(_s0, "%s", "		Exiting children of state SwingUpWait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state SwingUpWait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_update().type
		     	     		     ) {
		     	     			(*state).state = create_STATES_stm_ref0_SwingUpCompute();
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
		     	     		sprintf(_s0, "%s", "		State SwingUpWait is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_SwingUpCompute().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state SwingUpCompute");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_SwingUpCompute_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state SwingUpCompute");
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
		     	     		sprintf(_s0, "%s", "		Executing state SwingUpCompute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if ((memorystate)->cost < (memorystate)->balancing_threshold) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_balance();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else if ((memorystate)->cost >= (memorystate)->balancing_threshold) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_swing();
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
		     	     		sprintf(_s0, "%s", "		Exiting children of state SwingUpCompute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state SwingUpCompute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_balance().type
		     	     		     ) {
		     	     			if (!(state)->tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_done) {
		     	     				RESULT_Enum _ret_;
		     	     				_ret_ = tr_AcrobotSwingUpLQR_t_swing_compute_to_balance(state, inputstate, memorystate, output);
		     	     				return _ret_;
		     	     			} else {
		     	     				(*state).state = create_STATES_stm_ref0_BalanceWait();
		     	     				(*state).status = create_STATUS_ENTER_STATE();
		     	     				(*state).tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_done = false;
		     	     				(*state).tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_counter = 0;
		     	     				return create_RESULT_CONT();
		     	     			}
		     	     		} else if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_swing_compute_to_swing().type
		     	     		            ) {
		     	     			if (!(state)->tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_done) {
		     	     				RESULT_Enum _ret_;
		     	     				_ret_ = tr_AcrobotSwingUpLQR_t_swing_compute_to_swing(state, inputstate, memorystate, output);
		     	     				return _ret_;
		     	     			} else {
		     	     				(*state).state = create_STATES_stm_ref0_SwingUpWait();
		     	     				(*state).status = create_STATUS_ENTER_STATE();
		     	     				(*state).tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_done = false;
		     	     				(*state).tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_counter = 0;
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
		     	     		sprintf(_s0, "%s", "		State SwingUpCompute is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_BalanceWait().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state BalanceWait");
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
		     	     		sprintf(_s0, "%s", "		Entering children of state BalanceWait");
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
		     	     		sprintf(_s0, "%s", "		Executing state BalanceWait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if ((inputstate)->stateUpdate) {
		     	     			(*memorystate).su = (inputstate)->stateUpdate_value;
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_update();
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
		     	     		sprintf(_s0, "%s", "		Exiting children of state BalanceWait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state BalanceWait");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_update().type
		     	     		     ) {
		     	     			(*state).state = create_STATES_stm_ref0_BalanceCompute();
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
		     	     		sprintf(_s0, "%s", "		State BalanceWait is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
		else if ((*state).state.type == create_STATES_stm_ref0_BalanceCompute().type) {
		     	if ((*state).status.type == create_STATUS_ENTER_STATE().type) {
		     		{
		     			char _s0[256];
		     			sprintf(_s0, "%s", "		Entering state BalanceCompute");
		     			fprintf(log_file, "DEBUG: %s\n", _s0);
		     		}
		     		if (!(state)->en_AcrobotSwingUpLQR_BalanceCompute_1_done) {
		     			RESULT_Enum _ret_;
		     			_ret_ = en_AcrobotSwingUpLQR_BalanceCompute_1(state, inputstate, memorystate, output);
		     			return _ret_;
		     		} else {
		     			(*state).status = create_STATUS_ENTER_CHILDREN();
		     			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_done = false;
		     			(*state).en_AcrobotSwingUpLQR_BalanceCompute_1_counter = 0;
		     			return create_RESULT_CONT();
		     		}
		     	}
		     	else if ((*state).status.type == create_STATUS_ENTER_CHILDREN().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Entering children of state BalanceCompute");
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
		     	     		sprintf(_s0, "%s", "		Executing state BalanceCompute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_NONE().type
		     	     	     ) {
		     	     		if ((memorystate)->cost >= (memorystate)->balancing_threshold) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_swing();
		     	     			(*state).status = create_STATUS_EXIT_CHILDREN();
		     	     			return create_RESULT_CONT();
		     	     		} else if ((memorystate)->cost < (memorystate)->balancing_threshold) {
		     	     			(*inputstate)._transition_ = create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_balance();
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
		     	     		sprintf(_s0, "%s", "		Exiting children of state BalanceCompute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	(*state).status = create_STATUS_EXIT_STATE();
		     	     	return create_RESULT_CONT();
		     	     }
		     	else if ((*state).status.type == create_STATUS_EXIT_STATE().type) {
		     	     	{
		     	     		char _s0[256];
		     	     		sprintf(_s0, "%s", "		Exiting state BalanceCompute");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	{
		     	     		if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_swing().type
		     	     		     ) {
		     	     			if (!(state)->tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_done) {
		     	     				RESULT_Enum _ret_;
		     	     				_ret_ = tr_AcrobotSwingUpLQR_t_balance_compute_to_swing(state, inputstate, memorystate, output);
		     	     				return _ret_;
		     	     			} else {
		     	     				(*state).state = create_STATES_stm_ref0_SwingUpWait();
		     	     				(*state).status = create_STATUS_ENTER_STATE();
		     	     				(*state).tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_done = false;
		     	     				(*state).tr_AcrobotSwingUpLQR_t_balance_compute_to_swing_counter = 0;
		     	     				return create_RESULT_CONT();
		     	     			}
		     	     		} else if (	(*inputstate)._transition_.type == create_TRANSITIONS_stm_ref0_stm_ref0_t_balance_compute_to_balance().type
		     	     		            ) {
		     	     			if (!(state)->tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_done) {
		     	     				RESULT_Enum _ret_;
		     	     				_ret_ = tr_AcrobotSwingUpLQR_t_balance_compute_to_balance(state, inputstate, memorystate, output);
		     	     				return _ret_;
		     	     			} else {
		     	     				(*state).state = create_STATES_stm_ref0_BalanceWait();
		     	     				(*state).status = create_STATUS_ENTER_STATE();
		     	     				(*state).tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_done = false;
		     	     				(*state).tr_AcrobotSwingUpLQR_t_balance_compute_to_balance_counter = 0;
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
		     	     		sprintf(_s0, "%s", "		State BalanceCompute is inactive");
		     	     		fprintf(log_file, "DEBUG: %s\n", _s0);
		     	     	}
		     	     	return create_RESULT_CONT();
		     	     }
		     }
	}
	char* print_STATES_stm_ref0(STATES_stm_ref0_Enum* value) {
		if (value->type == STATES_stm_ref0_NONE) {
			return "NONE";
		}
		else if (value->type == STATES_stm_ref0_SwingUpWait) {
		     	return "SwingUpWait";
		     }
		else if (value->type == STATES_stm_ref0_SwingUpCompute) {
		     	return "SwingUpCompute";
		     }
		else if (value->type == STATES_stm_ref0_BalanceWait) {
		     	return "BalanceWait";
		     }
		else if (value->type == STATES_stm_ref0_BalanceCompute) {
		     	return "BalanceCompute";
		     }
	}
	RESULT_Enum en_AcrobotSwingUpLQR_SwingUpCompute_1(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running entry action 1 of state AcrobotSwingUpLQR_SwingUpCompute.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 0 ) {
			(*memory).theta1 = ((memory)->su).theta1;
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 1;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 1 ) {
			(*memory).theta2 = ((memory)->su).theta2;
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 2;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 2 ) {
			(*memory).dtheta1 = ((memory)->su).dtheta1;
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 3;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 3 ) {
			(*memory).dtheta2 = ((memory)->su).dtheta2;
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 4;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 4 ) {
			(*memory).x0 = ((memory)->theta1 - (memory)->PI);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 5;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 5 ) {
			(*memory).x1 = (memory)->theta2;
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 6;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 6 ) {
			(*memory).x2 = (memory)->dtheta1;
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 7;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 7 ) {
			(*memory).x3 = (memory)->dtheta2;
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 8;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 8 ) {
			(*memory).cost = (((((memory)->x0 * ((((((memory)->S00 * (memory)->x0) + ((memory)->S01 * (memory)->x1)) + ((memory)->S02 * (memory)->x2)) + ((memory)->S03 * (memory)->x3)))) + ((memory)->x1 * ((((((memory)->S10 * (memory)->x0) + ((memory)->S11 * (memory)->x1)) + ((memory)->S12 * (memory)->x2)) + ((memory)->S13 * (memory)->x3))))) + ((memory)->x2 * ((((((memory)->S20 * (memory)->x0) + ((memory)->S21 * (memory)->x1)) + ((memory)->S22 * (memory)->x2)) + ((memory)->S23 * (memory)->x3))))) + ((memory)->x3 * ((((((memory)->S30 * (memory)->x0) + ((memory)->S31 * (memory)->x1)) + ((memory)->S32 * (memory)->x2)) + ((memory)->S33 * (memory)->x3)))));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 9;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 9 ) {
			(*memory).M11 = ((((memory)->Ic1 + (memory)->Ic2) + (((memory)->m1 * (memory)->lc1) * (memory)->lc1)) + ((memory)->m2 * (((((memory)->l1 * (memory)->l1) + ((memory)->lc2 * (memory)->lc2)) + (((2.0 * (memory)->l1) * (memory)->lc2) * acrobot_cos((memory)->theta2))))));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 10;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 10 ) {
			(*memory).M12 = ((memory)->Ic2 + ((memory)->m2 * ((((memory)->lc2 * (memory)->lc2) + (((memory)->l1 * (memory)->lc2) * acrobot_cos((memory)->theta2))))));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 11;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 11 ) {
			(*memory).M22 = ((memory)->Ic2 + (((memory)->m2 * (memory)->lc2) * (memory)->lc2));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 12;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 12 ) {
			(*memory).detM = ((((memory)->M11 * (memory)->M22) - ((memory)->M12 * (memory)->M12)));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 13;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 13 ) {
			(*memory).a2 = ((-(memory)->M12) / (memory)->detM);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 14;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 14 ) {
			(*memory).a3 = (((memory)->M11) / (memory)->detM);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 15;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 15 ) {
			(*memory).KE = (0.5 * ((((((memory)->M11 * (memory)->dtheta1) * (memory)->dtheta1) + (((2.0 * (memory)->M12) * (memory)->dtheta1) * (memory)->dtheta2)) + (((memory)->M22 * (memory)->dtheta2) * (memory)->dtheta2))));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 16;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 16 ) {
			(*memory).PE = ((((-(memory)->m1 * (memory)->g) * (memory)->lc1) * acrobot_cos((memory)->theta1)) - (((memory)->m2 * (memory)->g) * ((((memory)->l1 * acrobot_cos((memory)->theta1)) + ((memory)->lc2 * acrobot_cos(((memory)->theta1 + (memory)->theta2)))))));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 17;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 17 ) {
			(*memory).E = ((memory)->PE + (memory)->KE);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 18;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 18 ) {
			(*memory).E_des = (((((memory)->m1 * (memory)->lc1) + ((memory)->m2 * (((memory)->l1 + (memory)->lc2))))) * (memory)->g);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 19;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 19 ) {
			(*memory).E_tilde = ((memory)->E - (memory)->E_des);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 20;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 20 ) {
			(*memory).u_e = ((-(memory)->k_e * (memory)->E_tilde) * (memory)->dtheta2);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 21;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 21 ) {
			(*memory).y = ((-(memory)->k_p * (memory)->theta2) - ((memory)->k_d * (memory)->dtheta2));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 22;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 22 ) {
			(*memory).C1 = ((((((-(memory)->m2 * (memory)->l1) * (memory)->lc2) * acrobot_sin((memory)->theta2)) * ((((2.0 * (memory)->dtheta1) * (memory)->dtheta2) + ((memory)->dtheta2 * (memory)->dtheta2)))) + ((((((memory)->m1 * (memory)->lc1) + ((memory)->m2 * (memory)->l1))) * (memory)->g) * acrobot_sin((memory)->theta1))) + ((((memory)->m2 * (memory)->lc2) * (memory)->g) * acrobot_sin(((memory)->theta1 + (memory)->theta2))));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 23;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 23 ) {
			(*memory).C2 = ((((((memory)->m2 * (memory)->l1) * (memory)->lc2) * acrobot_sin((memory)->theta2)) * (((memory)->dtheta1 * (memory)->dtheta1))) + ((((memory)->m2 * (memory)->lc2) * (memory)->g) * acrobot_sin(((memory)->theta1 + (memory)->theta2))));
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 24;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 24 ) {
			(*memory).u_p = ((((((memory)->a2 * (memory)->C1) + (memory)->y)) / (memory)->a3) + (memory)->C2);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 25;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 25 ) {
			(*memory).tau = ((memory)->u_e + (memory)->u_p);
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 26;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 26 ) {
			{
				pthread_barrier_wait(&output->can_write);
				output->value = create_stm_ref0_output_ApplyTorque((memory)->tau);
				pthread_barrier_wait(&output->can_read);
			}
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 27;
			return create_RESULT_CONT();
		} else if (	(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_counter == 27 ) {
			(*state).en_AcrobotSwingUpLQR_SwingUpCompute_1_counter = 28;
			return create_RESULT_WAIT();
		} else {
			(state)->en_AcrobotSwingUpLQR_SwingUpCompute_1_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_balance(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running transition action of transition AcrobotSwingUpLQR_t_swing_compute_to_balance.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_counter == 0 ) {
			(*state).tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_counter = 1;
			return create_RESULT_WAIT();
		} else {
			(state)->tr_AcrobotSwingUpLQR_t_swing_compute_to_balance_done = true;
			return create_RESULT_CONT();
		}
	}
	RESULT_Enum tr_AcrobotSwingUpLQR_t_swing_compute_to_swing(struct stm_ref0_state* state, struct stm_ref0_inputstate* inputstate, struct stm_ref0_memory* memory, stm_ref0_output_Enum_Channel* output) {
		{
			char _s0[256];
			sprintf(_s0, "%s", "Running transition action of transition AcrobotSwingUpLQR_t_swing_compute_to_swing.");
			fprintf(log_file, "DEBUG: %s\n", _s0);
		}
		if (	(state)->tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_counter == 0 ) {
			(*state).tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_counter = 1;
			return create_RESULT_WAIT();
		} else {
			(state)->tr_AcrobotSwingUpLQR_t_swing_compute_to_swing_done = true;
			return create_RESULT_CONT();
		}
	}



