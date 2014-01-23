angular.module('survey').controller 'SurveyCtrl', ($scope, $http, $rootScope, promiseTracker, $timeout) ->

  MAX_QUESTIONS = 12

  $scope.question = null
  $scope.nextQuestionId = null
  $scope.questionNumber = 1
  $scope.recipe = null
  $scope.firstId = 1
  $scope.previousId = 1
  $scope.answerIds = []
  $scope.takingSurvey = false
  $scope.surveyLoader = promiseTracker('survey', { minDuration: 300, maxDuration: 2000})

  # $scope.createGuestUser = ->
  #   $http
  #     url: '/api/users'
  #     method: 'post'
  #     data:
  #       user: null
  #   .success (data) ->
  #     # console.log 'guest created'

  # $scope.createGuestUser() unless $scope.isAuthenticated()

  $scope.getWidth = ->
    ((($scope.previousId - $scope.firstId)/ MAX_QUESTIONS) * 100) + '%'

  $scope.fetchQuestion = (answerId) ->
    $scope.previousId = answerId if answerId?
    $http 
      url: '/api/questions'
      method: 'GET'
      params:
        'previous_answer': answerId
      tracker: 'survey'
    .success (data) ->
      # wait = $timeout((->), 2000)
      # $scope.surveyLoader.addPromise(wait)
      $scope.firstId = data.id if answerId == null
      $scope.previousId = data.id
      $scope.takingSurvey = true 
      $scope.question = data

  $scope.fetchQuestion(null) 

  $scope.$on('$locationChangeStart', (event) ->
    if $scope.takingSurvey && !confirm("Please confirm you want to stop taking this survey")
      event.preventDefault()
  )


  $scope.advanceSurvey = (answerId, nextQuestionId) ->
    # $scope.answerIds.push answerId
    $scope.questionNumber++
    if nextQuestionId
      $scope.fetchQuestion(nextQuestionId)
    else
      $scope.displayRecipe()

  $scope.resetSurvey = ->
    $http
      url: '/api/survey_resets'
      method: 'post'
    .success (data) ->
      $scope.recipe = null
      User.setAuthenticated(false)
      $scope.previousId = $scope.firstId
      $scope.questionNumber = 1
      $scope.fetchQuestion(null)
