import { useMutation, useQueryClient } from "@tanstack/react-query";
import { updateUserRole } from "../api/usersApi";
import type { UserRole } from "../types/user";

export function useUpdateUserRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ userId, role }: { userId: string; role: UserRole }) =>
      updateUserRole(userId, role),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
  });
}
