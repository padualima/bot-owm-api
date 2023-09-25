class TweetPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # Apply custom scope to list only authenticated user's tweets
      scope.by_user(user)
    end
  end

  # def index?
  #   true # Qualquer usuário autenticado pode listar tweets
  # end

  def show?
    user.present? # Apenas usuários autenticados podem ver tweets individuais
  end

  def create?
    user.present? # Apenas usuários autenticados podem criar tweets
  end

  def update?
    user.present? && record.user == user # Apenas o autor do tweet pode atualizá-lo
  end

  def destroy?
    user.present? && record.user == user # Apenas o autor do tweet pode excluí-lo
  end
end
