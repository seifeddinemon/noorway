import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../core/locale_provider.dart';
import '../../core/quiz_provider.dart';
import '../../core/luxury_components.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;

    return LuxuryScaffold(
      title: AppStrings.get('knowledge_challenge', lang),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.royalGold));
          }

          final question = provider.currentQuestion;

          if (question == null) {
            return Center(
              child: Text(
                AppStrings.get('no_questions', lang),
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          return Stack(
            children: [
              ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                children: [
                  _buildScoreCard(provider, lang),
                  const SizedBox(height: 32),
                  _buildQuestionCard(question.text),
                  const SizedBox(height: 32),
                  ...List.generate(question.options.length, (index) {
                    return _buildOptionItem(provider, question, index);
                  }),
                  if (provider.isAnswerChecked) ...[
                    const SizedBox(height: 24),
                    _buildFeedbackCard(
                        provider.isCorrect ?? false, question, lang),
                  ],
                ],
              ),
              if (provider.isAnswerChecked)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildNextButton(provider, lang),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(QuizProvider provider, String lang) {
    return Center(
      child: LuxuryGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        borderRadius: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded,
                color: AppColors.royalGold, size: 24),
            const SizedBox(width: 12),
            Text(
              '${AppStrings.get('score', lang)}: ${provider.score}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(String text) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.menu_book_rounded,
              color: AppColors.royalGold, size: 40),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(QuizProvider provider, dynamic question, int index) {
    final isSelected = provider.selectedOptionIndex == index;
    final isCorrectOption = index == question.correctOptionIndex;
    final isAnswerChecked = provider.isAnswerChecked;

    List<BoxShadow>? boxShadow;

    if (isAnswerChecked) {
      if (isCorrectOption) {
        boxShadow = [
          BoxShadow(
              color: Colors.greenAccent.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2)
        ];
      } else if (isSelected) {
        boxShadow = [
          BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2)
        ];
      }
    } else if (isSelected) {
      boxShadow = [
        BoxShadow(
            color: AppColors.royalGold.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2)
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: isAnswerChecked
            ? null
            : () async {
                provider.selectAnswer(index);
                await provider.checkAnswer();
                if (provider.isCorrect == false) {
                  Vibration.vibrate(duration: 100);
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: LuxuryGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            boxShadow: boxShadow,
            gradient: isAnswerChecked && isCorrectOption
                ? LinearGradient(colors: [
                    Colors.greenAccent.withValues(alpha: 0.15),
                    Colors.greenAccent.withValues(alpha: 0.15)
                  ])
                : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question.options[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isAnswerChecked && isCorrectOption
                          ? Colors.greenAccent
                          : (isSelected ? AppColors.royalGold : Colors.white),
                    ),
                  ),
                ),
                if (isAnswerChecked && isCorrectOption)
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.greenAccent, size: 24),
                if (isAnswerChecked && isSelected && !isCorrectOption)
                  const Icon(Icons.cancel_rounded,
                      color: Colors.redAccent, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(bool isCorrect, dynamic question, String lang) {
    return LuxuryGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  isCorrect
                      ? Icons.celebration_rounded
                      : Icons.info_outline_rounded,
                  color: isCorrect ? Colors.greenAccent : AppColors.royalGold,
                  size: 28),
              const SizedBox(width: 12),
              Text(
                isCorrect
                    ? AppStrings.get('correct_answer_msg', lang)
                    : AppStrings.get('wrong_answer_msg', lang),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color:
                        isCorrect ? Colors.greenAccent : AppColors.royalGold),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Text(
              AppStrings.get('correct_answer_is', lang),
              style:
                  TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              question.options[question.correctOptionIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextButton(QuizProvider provider, String lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.15),
            Colors.black
          ],
        ),
      ),
      child: LuxuryGlassCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            provider.nextQuestion();
            _scrollController.animateTo(0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.isCorrect == true
                      ? AppStrings.get('next_question', lang)
                      : AppStrings.get('try_again', lang),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.royalGold),
                ),
                const SizedBox(width: 12),
                Icon(
                  provider.isCorrect == true
                      ? Icons.arrow_forward_rounded
                      : Icons.refresh_rounded,
                  color: AppColors.royalGold,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
