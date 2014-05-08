N2data <- read.csv(file = "C:\\Users\\Jason\\Dropbox\\MMath\\MDP\\Comparisons\\out\\L4L.csv",head = FALSE)

N2data$win = ifelse(N2data$V16/N2data$V8 <= 1 ,1,0)
N2data$S1 = N2data$V2 * N2data$V4
N2data$S2 = N2data$V3 * N2data$V5
N2data$Q = N2data$S1 / N2data$S2
summary(N2data)

reg <- glm(win ~  S1 + S2+ Q , data =N2data, family = "binomial")
summary(reg)

newdata1 <- with(N2data, data.frame( Q = mean(Q), S1 = mean(S1), S2 = mean(S2) ) )
newdata1$rankP <- predict(reg, newdata = newdata1, type = "response")
newdata2 <- with(N2data, data.frame(Q = rep(seq(from = 0.00000000001, to =1, length.out = 100),4),S1 = mean(S1),S2 = mean(S2) ) )
newdata3 <- cbind(newdata2, predict(reg, newdata = newdata2, type = "link",se = TRUE))
newdata3 <- within(newdata3, {
    PredictedProb <- plogis(fit)
    LL <- plogis(fit - (1.96 * se.fit))
    UL <- plogis(fit + (1.96 * se.fit))
})

pdf('C:\\Users\\Jason\\Dropbox\\MMath\\MDP\\Comparisons\\out\\RegQ.pdf')
plot(newdata3$Q,newdata3$PredictedProb)
dev.off()

newdata1 <- with(N2data, data.frame( Q = mean(Q),V1 = mean(V1),V7 = mean(V7),V6 = mean(V6), S1 = mean(S1), S2 = mean(S2) ) )
newdata1$rankP <- predict(reg, newdata = newdata1, type = "response")
newdata2 <- with(N2data, data.frame(S1 = rep(seq(from = 1, to =20, length.out = 100),4),Q = mean(Q),S2 = mean(S2) ) )
newdata3 <- cbind(newdata2, predict(reg, newdata = newdata2, type = "link",se = TRUE))
newdata3 <- within(newdata3, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})
pdf('C:\\Users\\Jason\\Dropbox\\MMath\\MDP\\Comparisons\\out\\RegS1.pdf')
plot(newdata3$S1,newdata3$PredictedProb)
dev.off()

newdata1 <- with(N2data, data.frame( Q = mean(Q),V1 = mean(V1),V7 = mean(V7),V6 = mean(V6), S1 = mean(S1), S2 = mean(S2) ) )
newdata1$rankP <- predict(reg, newdata = newdata1, type = "response")
newdata2 <- with(N2data, data.frame(S2 = rep(seq(from = 1, to =20, length.out = 100),4),S1 = mean(S1),Q = mean(Q) ) )
newdata3 <- cbind(newdata2, predict(reg, newdata = newdata2, type = "link",se = TRUE))
newdata3 <- within(newdata3, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})
pdf('C:\\Users\\Jason\\Dropbox\\MMath\\MDP\\Comparisons\\out\\RegS2.pdf')
plot(newdata3$S2,newdata3$PredictedProb)
dev.off()

