// import * as admin from "firebase-admin";
// import {HttpsError} from "firebase-functions/v1/https";

// export const checkAdminRole = async (uid: string) => {
//   const user = await admin.auth().getUser(uid);
//   if (!user.customClaims?.admin) {
//     throw new HttpsError("permission-denied", "You are not an admin");
//   }
// };
